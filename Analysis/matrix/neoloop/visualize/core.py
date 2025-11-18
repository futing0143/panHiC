#cython: language_level=3
#cython: boundscheck=False
#cython: cdivision=True

import itertools, matplotlib, neoloop, os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, LogNorm
from matplotlib.gridspec import GridSpec
from neoloop.visualize.bed import Genes, plotGenes, Elements
from neoloop.visualize.bigwig import plotSignal, SigTrack
from neoloop.visualize.loops import Loops
from neoloop.assembly import complexSV
from neoloop.callers import Peakachu
from scipy import sparse
from matplotlib import font_manager

plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['Arial'] 
plt.rcParams['pdf.fonttype'] = 42
font_files = font_manager.findSystemFonts(fontpaths='/cluster/home/futing/miniforge-pypy3/envs/HiC/fonts/')
 
for file in font_files:
    font_manager.fontManager.addfont(file)

new_rc_params = {'text.usetex': False,
"svg.fonttype": 'none'
}

matplotlib.rcParams.update(new_rc_params)

class GenomicRegionPlot:

	track_colors = {
		'CNV': '#666666',
		'RNA+': '#E31A1C',
		'RNA-': '#E31A1C',
		'RNA': '#E31A1C',
		'H3K27ac': '#6A3D9A',
		'DNase': '#6A3D9A',
		'4C': '#33A02C'
	}

	chrom_colors = {'chr1': '#B15928',
			'chr2': '#6A3D9A',
			'chr3': '#CAB2D6',
			'chr4': '#FDBF6F',
			'chr5': '#A6CEE3',
			'chr6': '#B2DF8A',
			'chr7': '#1B9E77',
			'chr8': '#A6CEE3',
			'chr9': '#33A02C',
			'chr10':'#E6AB02',
			'chr11':'#E58606',
			'chr12':'#5D69B1',
			'chr13':'#FF7F00',
			'chr14':'#52BCA3',
			'chr15':'#99C945',
			'chr16':'#CC61B0',
			'chr17':'#88CCEE',
			'chr18':'#1D6996',
			'chr19':'#117733',
			'chr20':'#661100',
			'chr21':'#882255',
			'chr22':'#1F78B4',
			'chrX':'#666666',
			'chrY':'#5F4690'
			}

	def __init__(self, clr, region, n_rows=3, track_partition=[4,0.1,0.3], 
					space=0.04, correct=True, figsize=(7, 4)):
		"""
		Recommended parameter settings.
		Initialize with a genomic region string like "chr8:126215000-130125000"    

		Set1: (Contact map + genes + chromosome bar)
			figsize=(7, 4)
			track_partition=[5, 0.2, 0.5]
			n_rows=3
			space=0.02
		
		Set2: (Contact map + genes + 1 signal track + chromosome bar)
			figsize=(7, 4.6)
			track_partition=[5, 0.2, 0.8, 0.5]
			n_rows=4
			genes: fontsize=7
			signal: data_range_size=7
			chromosome bar: name_size=7
		
		Set2_2: (Contact map + genes + cREs + chromosome bar)
			figsize=(7, 4.4)
			track_partition=[5, 0.3, 0.3, 0.5]
			n_rows=4
			genes: fontsize=7
			signal: data_range_size=7
			chromosome bar: name_size=7
		
		Set3: (Contact map + genes + 2 signal tracks + chromosome bar)
			figsize=(7, 5.2)
			track_partition=[5, 0.2, 0.8, 0.8, 0.5]
			n_rows=5
		
		Set4: (Contact map + genes + 3 signal tracks + chromosome bar)
			figsize=(7, 5.8)
			track_partition=[5, 0.2, 0.8, 0.8, 0.8, 0.5]
			n_rows=6
		
		Set5: (Contact map + genes + 4 signal tracks + chromosome bar)
			figsize=(7, 6.4)
			track_partition=[5, 0.2, 0.8, 0.8, 0.8, 0.8, 0.5]
			n_rows=7 
		
		Set6: (Contact map + genes + 5 signal tracks + chromosome bar)
			figsize=(7,7)
			track_partition=[5, 0.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.5]
			n_rows=8
		
		Set7: (Contact map + Arcs + 4C + genes + chromosome bar)
			figsize=(7, 5.2)
			track_partition=[5, 0.8, 0.8, 0.2, 0.5]
			n_rows=5

		"""
		self.clr = clr
		self.res = clr.binsize
		self.protocol = 'insitu'  # default protocol
		self.balance_type = correct  # default balance type
		
		# Parse the genomic region
		chrom, start, end = self.parse_region(region)
		self.chrom = chrom
		self.start = start
		self.end = end
		
		# Create a "fake" assembly-like structure
		self.assembly_ID = chrom
		self.bounds = [
			(0, (chrom, start)),
			((end-start)//self.res - 1, (chrom, end))
		]
		self.orients = ['+', '+']  # default orientation
		
		# Initialize figure and grid
		fig = plt.figure(figsize=figsize)
		self.fig = fig
		self.grid = GridSpec(n_rows, 1, figure=fig, left=0.1, right=0.9,
							bottom=0.1, top=0.9, hspace=space, 
							height_ratios=track_partition)
		self.track_count = 0
		self.w_h = figsize[0] / figsize[1]

		# Get the Hi-C matrix for this region
		self.matrix = self.get_region_matrix()
		self.sig_data = {}
		self.sig_tracks = {}

		# Define colormap
		self.cmap = LinearSegmentedColormap.from_list('interaction',
					['#FFFFFF','#FFDFDF','#FF7575','#FF2626','#F70000'])
		# 生成坐标映射表（确保与plot_loops中的bin算法完全一致）
		self.Map = {}  # {(chrom, pos): matrix_index}
		n_bins = self.matrix.shape[0]
		for i in range(n_bins):
			bin_start = self.start + i * self.res
			self.Map[(self.chrom, bin_start)] = i
		
		# # 调试输出
		# print(f"Map中的前5个bin坐标: {list(self.Map.items())[:5]}")
		# print(f"Map覆盖的区域: {self.chrom}:{min(k[1] for k in self.Map)}-{max(k[1] for k in self.Map)}")
		
	def parse_region(self, region_str):
		"""Parse a region string like 'chr8:126215000-130125000'"""
		chrom, pos = region_str.split(':')
		start, end = map(int, pos.split('-'))
		return chrom, start, end

	def get_region_matrix(self):
		"""Extract Hi-C matrix for the specified region"""
		region_str = f"{self.chrom}:{self.start}-{self.end}"
		mat = self.clr.matrix(balance=self.balance_type).fetch(region_str)
		
		# Convert to numpy array and make symmetric
		mat = np.triu(mat) + np.triu(mat, 1).T
		return mat

	def print_coordinate(self, pos):

		if pos % 1000000 == 0:
			return '{0}M'.format(pos//1000000)
		else:
			return '{0:.2f}M'.format(pos/1000000)

	def matrix_plot(self, colormap='traditional', vmin=None, vmax=None, log=False,
		cbr_width=0.02, cbr_height=0.1, cbr_fontsize=7, no_colorbar=False):

		h_ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1

		heatmap_pos = h_ax.get_position().bounds

		M = self.matrix
		n = M.shape[0]

		# Create the rotation matrix
		t = np.array([[1,0.5], [-1,0.5]])
		A = np.dot(np.array([(i[1],i[0]) for i in itertools.product(range(n,-1,-1),range(0,n+1,1))]),t)

		if colormap=='traditional':
			cmap = self.cmap
		else:
			cmap = colormap
		
		# Plot the Heatmap ...
		x = A[:,1].reshape(n+1, n+1)
		y = A[:,0].reshape(n+1, n+1)
		y[y<0] = -y[y<0]

		if vmax is None:
			vmax = np.percentile(M[M.nonzero()], 95)
		if vmin is None:
			vmin = M.min()
		
		if log:
			vmin = M[np.nonzero(M)].min()
			vmax = M.max()
			sc = h_ax.pcolormesh(x, y, np.flipud(M), cmap=cmap,
						edgecolor='none', snap=True, linewidth=.001,
						norm=LogNorm(vmin, vmax), rasterized=True)
		else:
			sc = h_ax.pcolormesh(x, y, np.flipud(M), vmin=vmin, vmax=vmax, cmap=cmap,
						edgecolor='none', snap=True, linewidth=.001, rasterized=True)
		
		h_ax.axis('off')
		self.heatmap_ax = h_ax
		self.hx = x
		self.hy = y
		
		# colorbar
		if not no_colorbar:
			c_ax = self.fig.add_axes([heatmap_pos[0]-0.02,
									(heatmap_pos[1]+0.9)/2,
									cbr_width,
									cbr_height])
			cbar = self.fig.colorbar(sc, cax=c_ax, ticks=[vmin, vmax], format='%.3g')
			c_ax.tick_params(labelsize=cbr_fontsize)
			self.cbar_ax = c_ax
		

	def plot_chromosome_bounds(self, line_color='k', linewidth=1.5, linestype=':'):

		n = self.matrix.shape[0]

		bounds = []
		for i in range(2, len(self.bounds), 2):
			bounds.append(self.bounds[i][0])
		
		for si in bounds:
			ei = n - 1
			x = [self.hx[:-1, :-1][n-1-si, si],
					self.hx[:-1, :-1][n-1-si, ei]]
			y = [self.hy[:-1, :-1][n-1-si, si] - 1,
					self.hy[:-1, :-1][n-1-si, ei] + 1]
			self.heatmap_ax.plot(x, y, color=line_color, linestyle=linestype,
				linewidth=linewidth)
		
		for ei in bounds:
			si = 0
			x = [self.hx[:-1, :-1][n-1-si, ei],
					self.hx[:-1, :-1][n-1-ei, ei]]
			y = [self.hy[:-1, :-1][n-1-si, ei] + 1,
					self.hy[:-1, :-1][n-1-ei, ei] - 1]
			self.heatmap_ax.plot(x, y, color=line_color, linestyle=linestype,
				linewidth=linewidth)
		
		self.heatmap_ax.set_xlim(self.hx.min(), self.hx.max())
		self.heatmap_ax.set_ylim(self.hy.min(), self.hy.max())

	def plot_neoTAD(self, ws=500000, color='#60636A'):

		from neoloop.tadtool.core import TADcaller
		import joblib

		hmm_folder = os.path.join(os.path.split(neoloop.__file__)[0], 'data')
		hmm = joblib.load(os.path.join(hmm_folder, 'HMM-model.pkl'))

		work = TADcaller(self.matrix, self.res, hmm, window_size=ws)
		work.callDomains()
		self.tads = work.loop_like()

		pairs = []
		for st, et, _ in self.tads:
			pairs.append((st+0.5, et+0.5))
			
		pairs.sort()

		tad_ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1
		tad_ax.set_xlim(self.hx.min(), self.hx.max())
		bottoms = np.r_[[i%2 for i in range(len(pairs))]]
		widths = np.r_[[d[1]-d[0] for d in pairs]]
		lefts = np.r_[[d[0] for d in pairs]]
		tad_ax.barh(bottoms, widths, 0.8, lefts, color=color,
					edgecolor='none')
		tad_ax.set_ylim(-0.5, 2.1)
		tad_ax.set_axis_off()
		self.tad_ax = tad_ax

	def plot_loops(self, loop_fil, marker_size=50, face_color='#1F78B4', 
				edgecolors='#1F78B4', marker_type='o', marker_alpha=1):
		Donuts = {}
		Bool = np.zeros(self.matrix.shape, dtype=bool)
		
		with open(loop_fil) as f:
			for line in f:
				parts = line.strip().split()
				if len(parts) < 6:
					continue
					
				chr1, start1 = parts[0], int(parts[1])
				chr2, start2 = parts[3], int(parts[4])
				
				# Find the closest bin for each coordinate
				bin1_pos = (start1 // self.res) * self.res
				bin2_pos = (start2 // self.res) * self.res
				
				bin1 = (chr1, bin1_pos)
				bin2 = (chr2, bin2_pos)
				
				# Check if the chromosomes match the region we're plotting
				if chr1 != self.chrom or chr2 != self.chrom:
					continue
					
				# Check if the positions are within our plotting region
				if (bin1_pos < self.start or bin1_pos >= self.end or 
					bin2_pos < self.start or bin2_pos >= self.end):
					continue
					
				# Convert genomic positions to matrix indices
				i = (bin1_pos - self.start) // self.res
				j = (bin2_pos - self.start) // self.res
				
				if i > j:  # Ensure upper triangle
					i, j = j, i
				
				Donuts[(i, j)] = float(parts[6]) if len(parts) > 6 else 1.0
				Bool[i, j] = True
				# print(f"bin_id 成功映射: {chr1}:{start1}->{i}, {chr2}:{start2}->{j}")  # Debug output
		
		# Store the Bool matrix for later use by other methods
		self.Bool = Bool  
		
		# Plot part remains unchanged
		lx = self.hx[:-1,:-1][np.flipud(Bool)]
		ly = self.hy[:-1,:-1][np.flipud(Bool)] + 1

		if lx.size > 0:
			self.heatmap_ax.scatter(lx, ly, s=marker_size, c=face_color, marker=marker_type,
								edgecolors=edgecolors, alpha=marker_alpha)
		
		self.heatmap_ax.set_xlim(self.hx.min(), self.hx.max())
		self.heatmap_ax.set_ylim(self.hy.min(), self.hy.max())
		print(f"Found {len(Donuts)} loops to plot")
		print("Example loops:", list(Donuts.items())[:3])  # Print first 3 loops
		

	def plot_DI(self, ws=2000000, pos_color='#FB9A99', neg_color='#A6CEE3', y_axis_offset=0.01,
		data_range_size=7):

		from tadlib.hitad.chromLev import Chrom
		from scipy.sparse import csr_matrix
		from neoloop.visualize.bigwig import plot_y_axis

		di_ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1
		
		hicdata = csr_matrix(self.matrix, shape=self.matrix.shape)
		tad_core = Chrom('chrN', self.res, hicdata, 'pseudo')
		tad_core._dw = min(tad_core._dw, hicdata.shape[0]-1)
		tad_core.windows = np.ones(hicdata.shape[0], dtype=int) * (ws // self.res)
		tad_core.calDI(tad_core.windows, 0)
		arr = tad_core.DIs

		pos_mask = arr >= 0
		neg_mask = arr < 0
		di_ax.fill_between(np.arange(arr.size), arr, where=pos_mask, color=pos_color,
							edgecolor='none')
		di_ax.fill_between(np.arange(arr.size), arr, where=neg_mask, color=neg_color,
							edgecolor='none')
		di_ax.set_xlim(self.hx.min(), self.hx.max())

		ymin, ymax = di_ax.get_ylim()
		ax_pos = di_ax.get_position().bounds
		y_ax = self.fig.add_axes([ax_pos[0]-y_axis_offset, ax_pos[1],
								y_axis_offset, ax_pos[3]])
		plot_y_axis(y_ax, ymin, ymax, size=data_range_size)
		self.clear_frame(y_ax)
		self.clear_frame(di_ax)

		self.di_ax = di_ax
		self.DI_arr = arr


	def plot_arcs(self, h_ratio=0.3, arc_color='#386CB0', arc_alpha=1,
		lw=1.5, cutoff='bottom', species='human', release=97, gene_filter=[]):
		"""
		Both plot_loops and plot_genes need to be called before this method.
		"""
		from matplotlib.patches import Arc

		arc_ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1
		arc_ax.set_xlim(self.hx.min(), self.hx.max())

		xs, ys = np.where(self.Bool)
		if not len(gene_filter):
			x, y = xs, ys
		else:
			# filter loops by genes
			refgenes = Genes(self.bounds, self.orients, self.res, species=species, release=release,
							filter_=gene_filter).genes
			pos = set()
			for g in gene_filter:
				for t in refgenes:
					if t[3] == g:
						for i in range(t[1]//self.res, t[2]//self.res+1):
							pos.add(i)
			x = []; y = []
			for i, j in zip(xs, ys):
				if (i in pos) or (j in pos):
					x.append(i+0.5)
					y.append(j+0.5)
		
		miny = maxy = 0
		for i, j in zip(x, y):
			mid = (i + j) / 2
			a, b = j - i, (j - i) * h_ratio
			if cutoff=='bottom':
				ty = b / 2 + 0.5
				if ty > maxy:
					maxy = ty
				arc_ax.add_patch(Arc((mid, 0), a, b, 
								theta1=0.0, theta2=180.0, edgecolor=arc_color, lw=lw, alpha=arc_alpha))
			else:
				ty = -b / 2 - 0.5
				if ty < miny:
					miny = ty
				arc_ax.add_patch(Arc((mid, 0), a, b, 
								theta1=180.0, theta2=360.0, edgecolor=arc_color, lw=lw, alpha=arc_alpha))
		
		arc_ax.set_ylim(miny, maxy)
		arc_ax.set_axis_off()
		self.arc_ax = arc_ax
		self.arc_x = x
		self.arc_y = y
			
	def plot_chromosome_bar(self, coord_ypos=0.3, name_ypos=0, coord_size=3.5, name_size=7,
		width=3, headwidth=8, remove_coord=False, color_by_order=[]):

		chrom_ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1
		chrom_colors = self.chrom_colors

		chrom_ax.set_xlim(self.hx.min(), self.hx.max())
		chrom_ax.set_ylim(0, 1)
		# chromosome bar
		n = self.matrix.shape[0]
		for i in range(0, len(self.bounds), 2):
			s = self.bounds[i][0]
			e = self.bounds[i+1][0]
			si = self.hx[:-1, :-1][n-1-s, s]
			ei = self.hx[:-1, :-1][n-1-e, e]
			o = self.orients[i//2]
			c = 'chr'+self.bounds[i][1][0].lstrip('chr')
			bar_color = chrom_colors[c]
			if len(color_by_order):
				bar_color = color_by_order[i//2]
			if o=='+':
				chrom_ax.annotate('', xy=(ei, 0.7), xytext=(si, 0.7),
						xycoords='data', arrowprops=dict(color=bar_color, shrink=0, width=width, headwidth=headwidth),
					)
			else:
				chrom_ax.annotate('', xy=(si, 0.7), xytext=(ei, 0.7),
						xycoords='data', arrowprops=dict(color=bar_color, shrink=0, width=width, headwidth=headwidth),
					)
			
			if not remove_coord:
				chrom_ax.text(si, coord_ypos, self.print_coordinate(self.bounds[i][1][1]),
						ha='left', va='top', fontsize=coord_size)
				chrom_ax.text(ei, coord_ypos, self.print_coordinate(self.bounds[i+1][1][1]),
						ha='right', va='top', fontsize=coord_size)
		
		# concatenate chromosome labels
		chroms = []
		for b in self.bounds:
			if not len(chroms):
				chroms.append([b[1][0], b[0], b[0]])
			else:
				if b[1][0] == chroms[-1][0]:
					chroms[-1][-1] = b[0]
				else:
					chroms.append([b[1][0], b[0], b[0]])
		
		unique_chrom_names = set([c[0] for c in chroms])
		for c in chroms:
			si = self.hx[:-1, :-1][n-1-c[1], c[1]]
			ei = self.hx[:-1, :-1][n-1-c[2], c[2]]
			if len(unique_chrom_names) > 1:
				chrom_ax.text((si+ei)/2, name_ypos, 'chr'+c[0].lstrip('chr'),
						ha='center', va='top', fontsize=name_size)
			else:
				chrom_ax.text((si+ei)/2, name_ypos-0.15, 'chr'+c[0].lstrip('chr'),
						ha='center', va='top', fontsize=name_size)
		
		chrom_ax.axis('off')

	def plot_genes(self, species='human', release=97, filter_=None,
		color='#999999', border_color='#999999', fontsize=7, labels='auto',
		style='flybase', global_max_row=False, label_aligns={}):

		genes = Genes(self.bounds, self.orients, self.res, species=species, release=release,
				filter_=filter_)
		_wk = plotGenes(genes.file_handler, color=color, fontsize=fontsize, labels=labels,
				style=style, global_max_row=global_max_row)
		
		ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1

		_wk.plot(ax, 'chrN', 0, self.matrix.shape[0]*self.res, label_aligns)

		ax.set_xlim(-self.res/2, self.matrix.shape[0]*self.res+self.res/2)
		ax.axis('off')

		self.gene_ax = ax
		self.genes = genes

	def plot_cREs(self, bedfil, color='#E41A1C', alpha=0.5):

		ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1

		eles = Elements(bedfil, self.bounds, self.orients, self.res)
		cREs = eles.cREs

		bottoms = np.zeros(len(cREs))
		widths = np.r_[[d[2]-d[1] for d in cREs]]
		lefts = np.r_[[d[1]+self.res/2 for d in cREs]]
		ax.barh(bottoms, widths, 0.8, lefts, color=color,
				edgecolor=color, alpha=alpha, linewidth=0)
		ax.set_ylim(-0.2, 1)
		ax.set_axis_off()
		ax.set_xlim(0, self.matrix.shape[0]*self.res+self.res)

		self.cRE_ax = ax

	def plot_motif(self, bedfil, plus_color='#444444', minus_color='#999999', ypos=0.5,
		marker_size=10, subset='+'):

		ax = self.fig.add_subplot(self.grid[self.track_count])
		self.track_count += 1

		eles = Elements(bedfil, self.bounds, self.orients, self.res)
		motifs = eles.cREs
		for m in motifs:
			x = (m[1] + m[2]) // 2
			strand = m[3]
			if strand != subset:
				continue
			if strand == '+':
				ax.scatter(x, ypos, s=marker_size, c=plus_color, marker='>')
			else:
				ax.scatter(x, ypos, s=marker_size, c=minus_color, marker='<')

		ax.set_ylim(0, 1)
		ax.set_axis_off()
		ax.set_xlim(0, self.matrix.shape[0]*self.res+self.res)
		self.motif_ax = ax
		

	def clear_frame(self, ax):

		for spine in ax.spines:
			ax.spines[spine].set_visible(False)
		
		ax.tick_params(axis='both', bottom=False, top=False, left=False, right=False,
			labelbottom=False, labeltop=False, labelleft=False, labelright=False)


	def plot_signal(self, track_name, bw_fil, factor=1, ax=None, color='auto', show_data_range=True,
		data_range_style='y-axis', data_range_size=7, max_value='auto', min_value='auto',
		y_axis_offset=0.01, show_label=True, label_size=7, label_pad=2, nBins=500,
		style_params={'type':'fill'}):
		'''
		Choices for data_range_style: ['y-axis', 'text'].
		'''
		sigs = SigTrack(bw_fil, self.bounds, self.orients, res=self.res, nBins=nBins,
						multiply=factor)
		# arr = sigs.stats('chrN', 0, self.matrix.shape[0]*self.res, 100)
		arr = sigs.stats('chrN', 0, self.matrix.shape[0]*self.res, nBins)
		# print(f"Signal array length: {len(arr)}, Expected bins: {nBins}")  # 调试输出
		# print(f"Region: chrN:0-{self.matrix.shape[0]*self.res}")  # 调试输出

		if color=='auto':
			if track_name in self.track_colors:
				color = self.track_colors[track_name]
			else:
				color = '#dfccde'

		if max_value=='auto':
			max_value = np.nanmax(arr)
		
		if min_value=='auto':
			min_value = 0

		# _wk = plotSignal(sigs, color=color, show_data_range='no',
		# 				max_value=max_value, min_value=min_value,
		# 				number_of_bins=self.matrix.shape[0] * sigs.factor)
		_wk = plotSignal(sigs, color=color, show_data_range='no',
                     max_value=max_value, min_value=min_value,
                     number_of_bins=nBins)  # 确保传递 nBins
		
		if ax is None:
			ax = self.fig.add_subplot(self.grid[self.track_count])
			self.track_count += 1
		else:
			ax = ax

		_wk.properties.update(style_params)
		_wk.plot(ax, 'chrN', 0, self.matrix.shape[0] * self.res)
		self.clear_frame(ax)

		if show_data_range:
			if data_range_style=='y-axis':
				ax_pos = ax.get_position().bounds
				y_ax = self.fig.add_axes([ax_pos[0]-y_axis_offset, ax_pos[1],
										y_axis_offset, ax_pos[3]])
				_wk.plot_y_axis(y_ax, size=data_range_size)
				self.clear_frame(y_ax)
			else:
				_wk.plot_range_text(min_value, max_value, data_range_size)
		
		if show_label:
			if show_data_range and (data_range_style=='y-axis'):
				y_ax.set_ylabel(track_name, rotation=0, va='center', ha='right',
					fontsize=label_size, labelpad=label_pad)
			else:
				ax.set_ylabel(track_name, rotation=0, va='center', ha='right', 
					fontsize=label_size, labelpad=label_pad)
		
		ax.set_xlim(-self.res/2, self.matrix.shape[0]*self.res+self.res/2)

		self.sig_data[track_name] = sigs
		self.sig_tracks[track_name] = ax
	
	def plot_vlines(self, positions, color='red', linestyle='-', linewidth=1.5, alpha=1.0):
		"""
		Draw vertical lines at specified genomic positions.
		
		Parameters
		----------
		positions : list of tuples
			List of (chr, start, end) tuples or (chr, pos) tuples.
			If end is provided, two vertical lines will be drawn at start and end.
			If only pos is provided, a single vertical line will be drawn at that position.
		color : str or list
			Color(s) for the vertical lines. Can be a single color or a list of colors.
		linestyle : str or list
			Line style(s) for the vertical lines. Can be a single style or a list of styles.
		linewidth : float or list
			Line width(s) for the vertical lines. Can be a single width or a list of widths.
		alpha : float or list
			Alpha value(s) for the vertical lines. Can be a single value or a list of values.
		"""
		if not isinstance(positions, list):
			positions = [positions]
		
		# Convert single values to lists if needed
		if not isinstance(color, list):
			color = [color] * len(positions)
		if not isinstance(linestyle, list):
			linestyle = [linestyle] * len(positions)
		if not isinstance(linewidth, list):
			linewidth = [linewidth] * len(positions)
		if not isinstance(alpha, list):
			alpha = [alpha] * len(positions)
		
		n = self.matrix.shape[0]
		
		for i, pos in enumerate(positions):
			if len(pos) == 2:  # (chr, pos) format
				chr_name, pos_value = pos
				# Only draw if chromosome matches
				if chr_name != self.chrom:
					continue
					
				# Check if position is within the plot region
				if pos_value < self.start or pos_value > self.end:
					continue
					
				# Convert genomic position to matrix index
				bin_idx = (pos_value - self.start) // self.res
				
				# Get the x-coordinate in the rotated heatmap
				x_coord = self.hx[:-1, :-1][n-1-bin_idx, bin_idx]
				
				# Draw vertical line through the entire heatmap
				self.heatmap_ax.axvline(x=x_coord, color=color[i], 
									linestyle=linestyle[i], 
									linewidth=linewidth[i], 
									alpha=alpha[i])
				
			elif len(pos) == 3:  # (chr, start, end) format
				chr_name, start_pos, end_pos = pos
				
				# Only draw if chromosome matches
				if chr_name != self.chrom:
					continue
					
				# Draw first vertical line at start position if within plot region
				if self.start <= start_pos <= self.end:
					start_bin_idx = (start_pos - self.start) // self.res
					x_start = self.hx[:-1, :-1][n-1-start_bin_idx, start_bin_idx]
					self.heatmap_ax.axvline(x=x_start, color=color[i], 
										linestyle=linestyle[i], 
										linewidth=linewidth[i], 
										alpha=alpha[i])
				
				# Draw second vertical line at end position if within plot region
				if self.start <= end_pos <= self.end:
					end_bin_idx = (end_pos - self.start) // self.res
					x_end = self.hx[:-1, :-1][n-1-end_bin_idx, end_bin_idx]
					self.heatmap_ax.axvline(x=x_end, color=color[i], 
										linestyle=linestyle[i], 
										linewidth=linewidth[i], 
										alpha=alpha[i])


	def outfig(self, outfile, dpi=200, bbox_inches='tight'):

		self.fig.savefig(outfile, dpi=dpi, bbox_inches=bbox_inches)

	def show(self):

		self.fig.show()

def plot_exp(exp, res, outfig, dpi=200):

	x = []
	y = []
	for i in sorted(exp):
		x.append(i*res)
		y.append(exp[i])

	fig = plt.figure(figsize=(5, 5))
	ax = fig.add_subplot(111)

	l1, = ax.plot(x, y)
	ax.set_xlabel('Genomic distance (bp)')
	ax.set_ylabel('Average contact frequency')

	ax.spines['top'].set_visible(False)
	ax.spines['right'].set_visible(False)
	ax.spines['bottom'].set_linewidth(1.5)
	ax.spines['left'].set_linewidth(1.5)

	ax.xaxis.set_tick_params(width=1.5)
	ax.yaxis.set_tick_params(width=1.5)

	ax.ticklabel_format(scilimits=(-3,3))

	plt.savefig(outfig, dpi=dpi, bbox_inches='tight')
	plt.close()
