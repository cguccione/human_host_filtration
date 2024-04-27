#!/bin/bash -l
# author: Caitlin Guccione (cguccion@ucsd.edu)
# date: 1/23/2024
# description: Script to run HPRC alignment on single interleaved FASTQ file.

config_fn=$2
source $config_fn
conda activate $CONDA_ENV_NAME

f=$1
basename=$(basename "$f" .fastq)

#Used for Daniel's splitter script
export delimiter=::MUX::
export r1_tag=/1
export r2_tag=/2

# verify index directory
if [ ! -d "$MINIMAP2_HPRC_INDEX_PATH" ] || [ -z "$(ls -A "$MINIMAP2_HPRC_INDEX_PATH"/*.mmi 2>/dev/null)" ]; then
  echo "Error: Index directory $MINIMAP2_HPRC_INDEX_PATH does not exist, is not a directory, or does not contain *.mmi files."
  exit 1
fi

# run minimap2 and samtools based on the mode (PE or SE)
new_basename="${basename%.*}"
cp "${f}" "${TMPDIR}"/seqs_${new_basename}.fastq
if [ "${MODE}" == "PE" ]; then
  for mmi in "${MINIMAP2_HPRC_INDEX_PATH}"/*.mmi
  do
    echo "Running minimap2 on ${mmi}"
    echo "First running in PE mode"
    minimap2 -2 -ax sr -t "${THREADS}" "${mmi}" "${TMPDIR}"/seqs_${new_basename}.fastq | \
      samtools fastq -@ "${THREADS}" -f 12 -F 256 -N -1 "${TMPDIR}/seqs_mmpe_R1_${new_basename}.fastq" -2 "${TMPDIR}/seqs_mmpe_R2_${new_basename}.fastq"
            
    rm "${TMPDIR}"/seqs_${new_basename}.fastq &

    echo "Next running in SE mode"
    minimap2 -2 -ax sr -t "${THREADS}" "${mmi}" <(cat "${TMPDIR}/seqs_mmpe_R1_${new_basename}.fastq" "${TMPDIR}/seqs_mmpe_R2_${new_basename}.fastq") | \
      samtools fastq -@ ${THREADS} -f 4 -F 256 -0 "${TMPDIR}/seqs_mmpese_${new_basename}.fastq"

    rm "${TMPDIR}/seqs_mmpe_R1_${new_basename}.fastq" &
    rm "${TMPDIR}/seqs_mmpe_R2_${new_basename}.fastq" &

    /home/mcdonadt/2023.08.09-pangenome-human-depletion/human-depletion-se-pe/splitter/target/release/splitter "${TMPDIR}/seqs_mmpese_${new_basename}.fastq" "${TMPDIR}/seqs_mmpese.${new_basename}.r1.fastq" ${delimiter} ${r1_tag} &
    /home/mcdonadt/2023.08.09-pangenome-human-depletion/human-depletion-se-pe/splitter/target/release/splitter "${TMPDIR}/seqs_mmpese_${new_basename}.fastq" "${TMPDIR}/seqs_mmpese.${new_basename}.r2.fastq" ${delimiter} ${r2_tag} &
    wait

    rm "${TMPDIR}/seqs_mmpese_${new_basename}.fastq" &

    /panfs/cguccion/22_06_22_HCC_CRC_Amir/micov/discover_fastqs/pe_se_host_depletion/fastq-pair/fastq_pair -t 50000000 "${TMPDIR}/seqs_mmpese.${new_basename}.r1.fastq" "${TMPDIR}/seqs_mmpese.${new_basename}.r2.fastq"
    rm "${TMPDIR}/seqs_mmpese.${new_basename}.r1.fastq.single.fq" &
    rm "${TMPDIR}/seqs_mmpese.${new_basename}.r2.fastq.single.fq" &
    rm "${TMPDIR}/seqs_mmpese.${new_basename}.r1.fastq" &
    rm "${TMPDIR}/seqs_mmpese.${new_basename}.r2.fastq" &
    wait

    mv "${TMPDIR}/seqs_mmpese.${new_basename}.r1.fastq.paired.fq" "${TMPDIR}/seqs_mmpese_p_r1_${new_basename}.fastq"
    mv "${TMPDIR}/seqs_mmpese.${new_basename}.r2.fastq.paired.fq" "${TMPDIR}/seqs_mmpese_p_r2_${new_basename}.fastq"

    #Now not in Daniel's code but need to interweave them
    seqtk mergepe "${TMPDIR}/seqs_mmpese_p_r1_${new_basename}.fastq" "${TMPDIR}/seqs_mmpese_p_r2_${new_basename}.fastq" > "${TMPDIR}/seqs_new_${new_basename}.fastq"

    mv "${TMPDIR}/seqs_new_${new_basename}.fastq" "${TMPDIR}"/seqs_${new_basename}.fastq
  done
elif [ "${MODE}" == "SE" ]; then
  continue
fi

mv "${TMPDIR}"/seqs_${new_basename}.fastq "${TMPDIR}/${new_basename}.ALIGN-HPRC.fastq"
