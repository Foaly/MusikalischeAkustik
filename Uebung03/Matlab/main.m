% read in filenames
files = dir('../Audio/*.wav');
numberOfFiles = length(files);

% tibretoolbox configuration
do_s.b_TEE                  = 1;        % Temporal Energy Envelope
do_s.b_STFTmag              = 0;
do_s.b_STFTpow              = 1;        % STFT Power Spectrum
do_s.b_Harmonic             = 1;        % Harmonic Fea tures
do_s.b_ERBfft               = 0;
do_s.b_ERBgam               = 0;
    
config_s.xcorr_nb_coeff     = 12;
config_s.threshold_harmo    = 0.01;     % tuned
config_s.nb_harmo           = 30;

% setup concurrent execution
system = gcp('nocreate');
if isempty(system)
    poolSize = 0;
else
    poolSize = system.NumWorkers;
end
if poolSize == 0
    system = parpool('local');
end

% analyze each file
tic;
%for n = 1:numberOfFiles                 % sequenziell
parfor n = 1:numberOfFiles              % parallel
    currentFile = [files(n).folder, '/', files(n).name];
    
    desc = Gget_desc_onefile(currentFile, do_s, config_s);
    tempModel = Gget_temporalmodeling_onefile(desc,0);
    
    % save temporal model
    saveToFile(files(n).name, tempModel);
    disp(['Done with file number ', num2str(n)]);
end

disp(['Elapsed time to extract all features: ', num2str(toc), ' s']);
