#!/bin/bash

# 默认参数值
STAGE="all"  # 默认运行所有阶段
dir=""
enzyme=""
juicerstage=""  # 新增参数，默认值为空

# 帮助信息
show_help() {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  -s, --stage STAGE     指定运行阶段: juicer, post, 或 all (默认: all)"
    echo "  -d, --dir DIR         指定目录参数"
    echo "  -e, --enzyme ENZYME   指定enzyme参数"
    echo "  -j, --juicerstage JSTAGE  指定juicerstage参数（可选）"
    echo "  -h, --help           显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -s juicer -d /path/to/dir -e enzyme1 -j mystage"
    echo "  $0 -s post -d /path/to/dir -e enzyme2"
    echo "  $0 -d /path/to/dir -e enzyme3  # 运行所有阶段"
}

# 参数解析
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -s|--stage)
            STAGE="$2"
            shift 2
            ;;
        -d|--dir)
            dir="$2"
            shift 2
            ;;
        -e|--enzyme)
            enzyme="$2"
            shift 2
            ;;
        -j|--juicerstage)  
            juicerstage="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 验证必需参数
if [[ -z "$dir" ]]; then
    echo "错误: 缺少必需的 --dir 参数"
    show_help
    exit 1
fi

if [[ -z "$enzyme" ]]; then
    echo "错误: 缺少必需的 --enzyme 参数"
    show_help
    exit 1
fi

# 验证stage参数
if [[ "$STAGE" != "juicer" && "$STAGE" != "post" && "$STAGE" != "all" ]]; then
    echo "错误: stage参数必须是 'juicer', 'post', 或 'all'"
    exit 1
fi

# 主执行逻辑
OS_INFO=$(uname -a)
echo "开始执行脚本..."
echo "Stage: $STAGE"
echo "Directory: $dir"
echo "Enzyme: $enzyme"
echo "Juicer stage: $juicerstage"
echo "系统信息: $OS_INFO"
echo ""


cell=$(basename ${dir})

time
cd $dir
# rm -r ./cool ./anno
mkdir -p ./{fastq,cool,anno}
rename _1 _R1 *fastq.gz
rename _2 _R2 *fastq.gz
rename .R1 _R1 *fastq.gz
rename .R2 _R2 *fastq.gz  

mv *.fastq.gz ./fastq
source activate /cluster2/home/futing/miniforge3/envs/juicer

# ------ Step 1: Run Juicer ------
if [[ "$STAGE" == "juicer" || "$STAGE" == "all" ]]; then
    echo -e "...Step 1: Running Juicer of ${cell} with enzyme ${enzyme} in directory ${dir}\n"
    
    if [ ! -f "./aligned/inter_30.hic" ]; then
        echo "Starting Juicer processing..."
		eval "/cluster2/home/futing/software/juicer_CPU/scripts/juicer2.sh \
			-D /cluster2/home/futing/software/juicer_CPU/ \
			-d \"$dir\" -g hg38 -t 20 \
			$juicerstage \
			-p /cluster2/home/futing/software/juicer_CPU/restriction_sites/hg38.genome \
			-z /cluster2/home/futing/software/juicer_CPU/references/hg38.fa -s \"$enzyme\""
        
        if [ $? -ne 0 ]; then
            echo -e "Error: juicer.sh failed to run successfully. Exiting script.\n" >&2
            exit 1
        fi
    else
        echo "Juicer output already exists, skipping Juicer step."
    fi

    # ------ Step 2: Convert HiC to cool files ------
    echo -e "...Step 2: Converting HiC to cool files\n"
    
    if [ ! -s "./cool/${cell}.mcool" ]; then
        echo "Starting HiC to cool conversion..."
        source activate /cluster2/home/futing/miniforge3/envs/juicer
        hicConvertFormat -m ./aligned/inter_30.hic \
            --inputFormat hic --outputFormat cool \
            -o ./cool/"${cell}".mcool

        resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
		mapfile -t actual_reso < <(cooler ls ./cool/${cell}.mcool | awk -F'/' '{print $NF}')
		intersection=()
		for reso in "${resolutions[@]}"; do
			for actual in "${actual_reso[@]}"; do
				if [[ "$reso" == "$actual" ]]; then
					intersection+=("$reso")
					break
				fi
			done
		done

        for resolution in "${intersection[@]}"; do
            echo "Balancing at resolution $resolution..."
            cooler balance ./cool/"${cell}".mcool::resolutions/"${resolution}"
        done
    else
        echo "Cool file already exists, skipping conversion step."
        # 仍然需要获取resolutions数组用于后续步骤
        resolutions=(1000 5000 10000 25000 50000 100000 250000 500000 1000000 2500000)
		mapfile -t actual_reso < <(cooler ls ./cool/${cell}.mcool | awk -F'/' '{print $NF}' | sed 's/\n/ /g')
		intersection=()
		for reso in "${resolutions[@]}"; do
			for actual in "${actual_reso[@]}"; do
				if [[ "$reso" == "$actual" ]]; then
					intersection+=("$reso")
					break
				fi
			done
		done
    fi

    # 处理各个分辨率
    for resolution in "${intersection[@]}"; do
        echo "Processing resolution $resolution..."
		if [ ! -s "./cool/${cell}_${resolution}.cool" ];then
        sh /cluster2/home/futing/Project/panCancer/scripts/mcool2cool_single.sh \
            "$resolution" ./cool/"${cell}".mcool ./cool
		else
		echo "[INFO] ./cool/${cell}_${resolution}.cool exits... "
		fi
    done
    
    echo "Processing completed at $(date)"
else
    echo -e "...Post-processing is enabled, skipping Juicer step.\n"
fi

# ------ Step 3: Generate annotation files ------
# loop
if [[ "$STAGE" == "post" || "$STAGE" == "all" ]]; then
    echo -e "\n=== 运行 Post 阶段 ===\n"
    echo "目录: $dir"
    echo "Enzyme: $enzyme"

    # define sbatch parameters
    queue="normal"
    queue_time="5780"
    debugdir="${dir}/debug"
	
    submit_job() {
    local name=$1
    local script_path=$2
    local dependency=$3

    local dep_opt=()
    if [ -n "$dependency" ]; then
        dep_opt=(--dependency=afterok:$dependency)
    fi

    sbatch "${dep_opt[@]}" <<- EOF | egrep -o -e "\b[0-9]+$"
#!/bin/bash -l
#SBATCH -p $queue
#SBATCH -t $queue_time
#SBATCH --mem=32G
#SBATCH --cpus-per-task=3
#SBATCH --output=$debugdir/$name-%j.log
#SBATCH -J "${name}"

date
sh $script_path
date
EOF
}

    
    scripts=/cluster2/home/futing/Project/panCancer/scripts

    if [ ! -f ${dir}/cool/${cell}_1000.cool ];then 
        echo -e "...Cool files not found, skipping annotation generation.\n"
        exit 1
    else
        echo -e "...Step 3: Generating annotation files\n"
        
        # 第一个任务没有依赖
        echo -e "...3-1: Generating GC content file\n"
        jid_PC=$(submit_job "${cell}_PC" "${scripts}/PC_single.sh ${dir}")
        echo "${cell}_PC Job ID: $jid_PC"

        # OnTAD 和 insul 依赖 PC 任务
        echo -e "...3-2: running OnTAD\n"
        jid_OnTAD=$(submit_job "${cell}_OnTAD" "${scripts}/OnTAD_single.sh ${dir} 50000" "$jid_PC")
        echo "${cell}_OnTAD Job ID: $jid_OnTAD"
        
        jid_insul=$(submit_job "${cell}_insul" "${scripts}/insul_single.sh ${dir}" "$jid_PC")
        echo "${cell}_insul Job ID: $jid_insul"
		jid_insul2=$(submit_job "${cell}_insul" "${scripts}/insul_single.sh ${dir} 50000" "$jid_PC")
        echo "${cell}_insul Job ID: $jid_insul2"

        # stripenn 和 stripecaller 依赖 OnTAD 和 insul 都完成
        echo -e "...3-3: running stripe\n"
        jid_stripenn=$(submit_job "${cell}_stripenn" "${scripts}/stripenn_single.sh ${dir}" "$jid_OnTAD,$jid_insul")
        echo "${cell}_stripenn Job ID: $jid_stripenn"
        
        jid_stripecaller=$(submit_job "${cell}_stripecaller" "${scripts}/stripecaller_single.sh ${dir} 50000" "$jid_OnTAD,$jid_insul")
        echo "${cell}_stripecaller Job ID: $jid_stripecaller"

        # 后续任务依赖 stripe 任务完成
        echo -e "...3-4: running loops\n"
        jid_dots1=$(submit_job "${cell}_dots" "${scripts}/dots_single.sh ${dir}" "$jid_stripenn,$jid_stripecaller")
        echo "${cell}_dots Job ID: $jid_dots1"
        
        jid_dots2=$(submit_job "${cell}_dots" "${scripts}/dots_single.sh ${dir} 10000" "$jid_dots1")
        echo "${cell}_dots Job ID: $jid_dots2"
        
        jid_peakachu=$(submit_job "${cell}_peakachu" "${scripts}/peakachu_single.sh ${dir}" "$jid_dots2")
        echo "${cell}_peakachu Job ID: $jid_peakachu"
		jid_peakachu2=$(submit_job "${cell}_peakachu" "${scripts}/peakachu_single.sh ${dir} 10000" "$jid_dots2")
        echo "${cell}_peakachu Job ID: $jid_peakachu2"
        
        jid_mustache=$(submit_job "${cell}_mustache" "${scripts}/mustache_single.sh ${dir}" "$jid_peakachu2")
        echo "${cell}_mustache Job ID: $jid_mustache"
		jid_mustache2=$(submit_job "${cell}_mustache" "${scripts}/mustache_single.sh ${dir} 10000" "$jid_peakachu2")
        echo "${cell}_mustache Job ID: $jid_mustache2"
        
        jid_fithic=$(submit_job "${cell}_fithic" "${scripts}/fithic_single.sh ${dir}" "$jid_mustache2")
        echo "${cell}_fithic Job ID: $jid_fithic"
		jid_fithic2=$(submit_job "${cell}_fithic" "${scripts}/fithic_single.sh ${dir} 10000" "$jid_fithic")
        echo "${cell}_fithic Job ID: $jid_fithic2"

    fi

fi