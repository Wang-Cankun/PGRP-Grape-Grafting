####### Libraries #######
from utils import findLibraries

####### Global variables #######
EXTENSION = config["reads"]["extension"]
PREFIX = config["reads"]["prefix"]
READS_PATH = config["reads"]["path"]
FORWARD_READ_ID = config["reads"]["forward_read_id"]
SUFFIX = "_" + FORWARD_READ_ID + "." + EXTENSION
LIBS = findLibraries(READS_PATH,PREFIX,SUFFIX)
RAW_ENDS = "_R1"

###### Multithread configuration #####
CPUS_FASTQC = 4

####### Output directories #######
LOGS = "0.LOGS/"
RAW_FASTQC = "1.QC.RAW/"
REPORTS = "999.REPORTS/"

####### Rules #######
rule all:
    input:
        expand(RAW_FASTQC + "{raw_reads}{raw_ends}_fastqc.{format}",
            raw_reads = LIBS, raw_ends = RAW_ENDS, format = ["html","zip"])
        # expand(RAW_FASTQC + "{raw_reads}{raw_ends}_fastqc.{format}",
        #     raw_reads = LIBS, raw_ends = [1, 2], format = ["html","zip"])
    output:
        expand(REPORTS + "Report_{step}.html", step = ["FastQC_Raw"])
    params:
        logs 	= directory(LOGS),
        reports	= directory(REPORTS)
    run:
        shell("multiqc -f -o {params.reports} -n Report_FastQC_Raw.html -d " + RAW_FASTQC)

rule fastqc_raw:
    input:
        reads = READS_PATH + "{raw_reads}{raw_ends}." + EXTENSION
    output:
        html = RAW_FASTQC + "{raw_reads}{raw_ends}_fastqc.html",
        zip  = RAW_FASTQC + "{raw_reads}{raw_ends}_fastqc.zip"
    message:
        "FastQC on raw data"
    log:
        RAW_FASTQC + "{raw_reads}{raw_ends}.log"
    threads:
        CPUS_FASTQC
    shell:
        "fastqc -o " + RAW_FASTQC + " -t {threads} {input.reads} 2> {log}"
