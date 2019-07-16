#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

readonly EXEC_PATH=${USE_EXEC_PATH:-"/usr/local/bin"}
readonly INFILE=$1
readonly OUTDIR=$2
readonly SAMPLESURL=${3:-"none"}

function usage {
    echo >&2 "$0 infile outdir [samplesurl]: split a vcf. "
    echo >&2 "       infile: input vcf/bcf/vcf.gz file to split"
    echo >&2 "       outdir: output directory to put single-sample VCFs"
    echo >&2 "       samplesurl: optional url containing sample names."
    echo >&2 "                    if not provided, all samples are generated"
    exit 1
}

###
### Make sure input and output files provided
###
if [[ -z "${INFILE}" ]] || [[ -z "${OUTDIR}" ]] 
then
    echo >&2 "Missing arguments."
    usage
fi


###
### All samples
###
if [[ ${SAMPLESURL} == "none" ]]
then
    "${EXEC_PATH}/bcftools" +split -Oz -o "${OUTDIR}" "${INFILE}"
else
###
### specified samples
### 
    readonly SAMPLES=$( curl ${SAMPLESURL} )
    for sample in ${SAMPLES}
    do
        "${EXEC_PATH}/bcftools" view -c1 -Oz -s "${sample}" "${INFILE}" \
            | "${EXEC_PATH}/bcftools" filter -e 'GT="0/0" || GT="./."' \
            -Oz -o "${OUTDIR}/${sample}.vcf.gz"
    done
fi
