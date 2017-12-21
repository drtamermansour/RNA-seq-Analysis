#!/bin/bash
#downloading and installing the required programms for hisat/stringtie and star/scallop pipelines 

work_dir="$(pwd)"


### Download the human genome data, generate genome sizes file and generate hisat/star indexes ###
 
wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/GRCh38.primary_assembly.genome.fa.gz -p $work_dir/hg38_data/ #download the fasta file for indexes generating
gunzip -c $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa.gz > $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa

Wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.annotation.gtf.gz -p $work_dir/hg38_data/ #download transcriptome gtf file to use for comparison 
gunzip -c gencode.v27.annotation.gtf.gz > $work_dir/hg38_data/gencode.v27.annotation.gtf

samtools faidx $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa
cut -f1,2 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa.fai > $work_dir/hg38_data/hg38.genome

#hisat genome indexing without gtf annotation
mkdir $work_dir/hg38_data/hisat_index
hisat2-build -p 8 $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa $work_dir/hg38_data/hisat_index/hg38

#star genome indexing without gtf annotation
mkdir $work_dir/hg38_data/star_index
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir $work_dir/hg38_data/star_index/ --genomeFastaFiles $work_dir/hg38_data/GRCh38.primary_assembly.genome.fa

### done ###


cd $work_dir/programs_workDir/

### download SRA toolkit required for downloading reads ### 
wget ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar xvzf sratoolkit.2.8.2-1-ubuntu64.tar.gz

#copying the code file -that will download the reads and convert them into fastq- to the PATH
#sudo cp /home/$username/sratoolkit.2.8.2-1-ubuntu64/bin/fastq-dump /usr/bin/

### done ### 



### required downloads for hisat-stringtie pipeline ###
   
git clone https://github.com/infphilo/hisat2 #installing Hisat2

wget https://github.com/samtools/samtools/releases/download/1.6/samtools-1.6.tar.bz2 #downloadeing samtools-1.6
tar jxvf samtools-1.6.tar.bz2
cd samtools-1.6
make
cd ../

git clone https://github.com/gpertea/stringtie #installing StringTie-1.3.4
cd stringtie
make release
cd ../

sudo apt-get install bedtools #install bedtools

git clone https://github.com/gpertea/gclib #installing dependancy of gffcompare
git clone https://github.com/gpertea/gffcompare #installing gffcompare-0.10.1
cd gffcompare
make release
cd ../

### done ### 



### required downloads for star-scallop pipeline ###

#Installing scallop dependancies
wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz #getting boost folder
tar xvzf boost_1_65_1.tar.gz

#getting & installing zlib required for htslib
wget https://zlib.net/zlib-1.2.11.tar.gz 
tar xvzf zlib-1.2.11.tar.gz 
cd zlib-1.2.11/
./configure
make
sudo make install
cd ../

#cloning & installing htslib
git clone https://github.com/samtools/htslib 
cd htslib/
autoheader
autoconf
./configure --disable-bz2 --disable-lzma --disable-gcs --disable-s3 --enable-libcurl=no
make 
sudo make install
cd ../

#install subversion requiered for ClP
sudo apt-get install subversion 
svn co https://projects.coin-or.org/svn/Clp/stable/1.16 coin-Clp #getting & installing clp
cd coin-Clp
./configure --disable-bzlib --disable-zlib
make
sudo make install 
cd ../

#Installing Scallop
git clone https://github.com/Kingsford-Group/scallop
cd scallop/ 
autoreconf --install       	
autoconf configure.ac
./configure --with-clp=/home/$username/coin-Clp --with-htslib=/home/$username/htslib --with-boost=/home/$username/boost_1_65_1
make
cd ../

#downloading STAR and unziping it
wget https://github.com/alexdobin/STAR/archive/2.5.3a.tar.gz 
tar xvzf STAR-2.5.3a.tar.gz

#downloading cufflinks to merge scallop GTFs 
wget cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz
tar xvzf cufflinks-2.2.1.Linux_x86_64.tar.gz

### done ###

cd ../
 
