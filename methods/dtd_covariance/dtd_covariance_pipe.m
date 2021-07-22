function fn = dtd_covariance_pipe(s, paths, opt, ind)
% function fn = dtd_covariance_pipe(s, paths, opt)
%
% s     - input structure
% paths - either a pathname or a path structure (see mdm_paths)
% opt   - (optional) options that drive the pipeline
%         opt.mask.thresh = 0.1, you may want to adjust it 
%            
% fn    - a cell arary with filenames to generated nii files

if ( (nargin < 2) || isempty(paths) ), paths = fileparts(s.nii_fn); end
if (nargin < 3), opt.present = 1; end
if (nargin < 4), ind = ones(s.xps.n, 1, 'logical'); end

% Init structures
opt   = mdm_opt(opt);
opt   = dtd_covariance_opt(opt);

paths = mdm_paths(paths, 'dtd_covariance');   

msf_log(['Starting ' mfilename], opt);

% Check that the xps is proper
dtd_covariance_check_xps(s.xps, opt);

% Smooth and prepare mask
s = mdm_s_smooth(s, opt.filter_sigma, paths.nii_path, opt);
s = mdm_s_mask(s, @mio_mask_threshold, paths.nii_path, opt);

% Fit and derive parameters
mdm_data2fit(@dtd_covariance_4d_data2fit, s, paths.mfs_fn, opt, ind);
mdm_fit2param(@dtd_covariance_4d_fit2param, paths.mfs_fn, paths.dps_fn, opt);

% Save niftis
fn = mdm_param2nii(paths.dps_fn, paths.nii_path, opt.dtd_covariance, opt); 

