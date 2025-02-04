# BASSA
BASSA is a GUI-based software tool for time-frequency analysis of low frequency animal vocalisations.

To install BASSA: 
- Either sync this repository to your local Git folder, or click the green "Code" button and then in the "Local" tab, click "Download Zip".
- In the BASSA repository is the file "BASSA User Guide Beta V1.0.pdf". Open this and review system requirements and installation information. 
- Open the folder "BASSA Installation", and run "BASSA_installer_web.exe".

## Installation Update (2025-02-04)
Some users have reported an error relating to a missing MEX file when launching BASSA. 
To resolve this issue, an installer-less version of the software has been uploaded as a release (v1.0-alpha).
It is available here: https://github.com/b-jancovich/BASSA/releases/tag/v1.0-alpha

## How To Contribute To Bassa

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

## How to Cite BASSA
BASSA is released under the MIT licence. This is a permissive licence that allows re-use. 
The conditions of re-use are:
1) Any work based on, or incorporating code from this repo must be released under the same MIT licence.
2) Any work that utilises BASSA or any of its underlying code, must include the following citation:
 
Jancovich, B. A., & Rogers, T. L. (2024). BASSA: New software tool reveals hidden details in visualisation of low-frequency animal sounds. 
Ecology and Evolution, 14, e11636. https://doi.org/10.1002/ece3.11636 

BASSA was developed at the MammalLab
<br> Centre for Marine Science and Innovation
<br>School of Biological, Earth and Environmental Sciences
<br>University of New South Wales, Sydney, Australia
