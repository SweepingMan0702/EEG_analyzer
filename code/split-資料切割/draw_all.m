path = uigetdir(pwd, 'Select a folder');
list = {'base','working','fatigue','recovered'};
for k = 1:length(list)
    temp_path = [path '\' list{k}];
    matFiles = dir(fullfile(temp_path, '*.mat'));

for j = 1:length(matFiles)
    fileName = fullfile(temp_path, matFiles(j).name);
    disp(fileName);
    load(fileName);
    % 在這裡處理加載的數據
    

    cz = segment_data(1,:);
    fz = segment_data(2,:);
    figure;
    subplot(2,1,1);
    spectrogram(cz, 1250, 1125, 1024, 250, 'yaxis');
    ylim([0 60]);
    clim([-10,20]);
    colormap('turbo');
    grid on;
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
    title('CZ Spectrogram');
    
    subplot(2,1,2);
    spectrogram(fz, 1250, 1125, 1024, 250, 'yaxis');
    title('FZ Spectrogram');  
    ylim([0 60]);
    clim([-10,20]);
    grid on;
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
    colormap('turbo');
    saveas( gcf ,[path '\' list{k} '.png']);

end
end