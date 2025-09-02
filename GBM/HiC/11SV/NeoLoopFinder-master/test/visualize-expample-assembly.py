from neoloop.visualize.core import * 
import cooler

clr = cooler.Cooler('./SKNMC-MboI-allReps-filtered.mcool::/resolutions/25000')

# for the assembly ID, just copy any one line from K562.assemblies.txt
assembly = 'C0	translocation,1,10260000,+,X,21495000,-	1,8725000	X,24150000'

vis = Triangle(clr, assembly, n_rows=3, figsize=(7, 4.2), track_partition=[5, 0.4, 0.5])

# plot the contact heatmap in triangle
vis.matrix_plot(vmin=0)

# plot the breakpoint/boundary lines
vis.plot_chromosome_bounds(linewidth=2.5)

# plot loops on the heatmap
vis.plot_loops('./SKNMC.neo-loops.txt', face_color='none', marker_size=40, cluster=True)

# plot genes, it might take a long time if this is the first time you run this command
vis.plot_genes(filter_=['PRAME','BCRP4', 'RAB36', 'BCR', 'ABL1', 'NUP214'],label_aligns={'PRAME':'right','RAB36':'right'}, fontsize=9) 

# plot the chromosome bars under the gene track
vis.plot_chromosome_bar(name_size=11, coord_size=4.8)

# save the figure in pdf
vis.outfig('./SKNMC.pdf')