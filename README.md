# BASSA
BASSA is a GUI-based software tool for time-frequency analysis of low frequency animal vocalisations.

To install BASSA: 
- Either sync this repository to your local Git folder, or click the green "Code" button and then in the "Local" tab, click "Download Zip".
- In the BASSA repository is the file "BASSA User Guide Beta V1.0.pdf". Open this and review system requirements and installation information. 
- Open the folder "BASSA Installation", and run "BASSA_installer_web.exe".

To submit source code changes to BASSA:
- Sync the BASSA repo
- The majority of BASSA's source code is contained within the file "BASSA.mlapp", which must be opened and edited with the MATLAB App Designer.
- To work with the BASSA source code, the following additional dependencies are required:
  - Superlet Transform: https://github.com/TransylvanianInstituteOfNeuroscience/Superlets
  - Utilities: https://github.com/b-jancovich/time_freq_analysis
  - FFTW library: https://www.fftw.org/download.html
- The Superlets transform is implementaed in BASSA using a "mex" file. This is C code, compiled to run inside MATLAB.
- To modify BASSA's source, you will likely need to build your own version of the mex. Follow instructions at https://github.com/TransylvanianInstituteOfNeuroscience/Superlets.
- Make changes in a git forked repo.
- Push your development branch to the forked remote repository and create the pull request as described here: https://help.github.com/articles/using-pull-requests
- Once reviewed, your repository will be added as a new remote repository, your changes will be fetched and your development branch will be merged back into the master branch. 

Contact the developer: b.jancovich@unsw.edu.au
