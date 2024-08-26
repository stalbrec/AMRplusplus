#!/usr/bin/env python
from __future__ import print_function
import argparse
import os
import subprocess
from pathlib import Path


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", choices=[3,1], default=1, type=int, help="version of AMR++ pipeline (1: replication of old galaxy v1 workflow, 3: default \"new\" version.)")
    parser.add_argument("--reads", type=str, help="path to read pairs or alternatively a file containing a list of pairs.")
    parser.add_argument("--profile",choices=["conda","local"], default="local")
    parser.add_argument("--dedup", action="store_true", help="specfify in order to enable deduplication in AMR++ pipeline.")
    parser.add_argument("--debug", action="store_true", help="do not execute anything. just print the commands for debugging.")
    parser.add_argument("--output", type=str, help="optional: specify where to store results. default is wherever reads are located")
    parser.add_argument("--threads", type=int, default=10, help="number of threads parameter passed on to nextflow")
    parser.add_argument("--host", default="data/host/chr21.fasta.gz", help="path to host genome fasta for host-removal.")
    parser.add_argument("--snp", action="store_true", help="Perform SNP analysis.")
    parser.add_argument("--pipeline", default="standard_AMR", choices=["standard_AMR","standard_AMR_wKraken"], help="specify which AMR++ pipeline you want to run.")
    args = parser.parse_args()

    check_tools = ["nextflow"]

    user_workdir = Path(".workdir_{}".format(os.environ["USER"]))
    if(not os.path.exists(user_workdir)):
        print("creating user workdir: {}".format(user_workdir))
        os.makedirs(user_workdir)
 
    def resolve_path(rel):
        return Path(rel).expanduser().resolve()
    __script_dir__ = Path(__file__).resolve().parent

    kraken_db = os.environ.get("KRAKEN2_DB", "/home/admin/seq_tools/kraken2/kraken2_DB")
    kraken_db = resolve_path(kraken_db)

    if args.profile == "local":
        check_tools += ["bwa", "samtools"]

    for tool in check_tools:
        try:
            subprocess.call([tool], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except BaseException:
            raise RuntimeError("Could not find depency \"{}\". Make sure your environment is setup correctly.".format(tool))

    cmd = "nextflow run {}/main_AMR++.nf -profile {}".format(__script_dir__, args.profile)

    cmd += " --pipeline {} ".format(args.pipeline)

    if args.version == 1:
        cmd += " --legacy Y --slidingwindow '4:20' --threshold 1 --min 1 --skip 1 "
    if args.dedup:
        cmd += " --deduped N "

    cmd += " --kraken_db \"{}\"".format(kraken_db)

    cmd += " --threads {} ".format(args.threads)
    
    def process_reads(cmd_, reads_pattern, output_dir):
        reads_pattern = resolve_path(reads_pattern)
        cmd_ += " --reads \"{}\" ".format(reads_pattern)

        if output_dir is None:
            output_dir = reads_pattern.parent
        else:
            output_dir = resolve_path(output_dir)

        if not os.path.exists(output_dir):
            raise NotADirectoryError("The specified output directory ({}) does not exist!".format(output_dir))
        
        cmd_ += " --output \"{}\" ".format(output_dir)

        print("executing: " + cmd_)
        cwd = os.getcwd()
        if not args.debug:
            os.chdir(user_workdir)
            os.system(cmd_)
            os.chdir(cwd)

    if "{" in args.reads:
        process_reads(cmd, args.reads, args.output)
    elif os.path.exists(args.reads):
        for reads in open(args.reads,"r"):
            process_reads(cmd, reads.strip(), args.output)
