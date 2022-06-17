function [output] = Impl_Segmentation(imgPath,extension)

 imgPopulations = dir(strcat(imgPath, extension)); % Cargar todas las muestras de entrenamiento 
 finalDir = strcat(imgPath, 'Masks');
 if ~exist('',finalDir)
     mkdir(finalDir);
 end    
 for k = 1:length(imgPopulations)           % Recorrer las imagenes          
    imgfile = imgPopulations(k).name;       % Nombre del imagen       
    populationName = strrep(imgfile,'.tif','') 
    if exist(strcat(imgPath, 'Masks/', strcat(populationName,'.mat')),'file')         % si el archivo existe continua con el siguiente.        
       continue;
    end   

    I_rgb = imread(strcat(imgPath,imgfile));    % Lectura de la imagen    
    Lab = ColorCalibration(I_rgb);  
    disp([datestr(datetime), ' Segmentados ']);
    Mask = ColorRegionGrowingLab(I_rgb, Lab, 0);     % crecimiento de region  
    Mask = ~Mask;
    % Clean up small groups pixels
    [ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
    propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
    s=find([propied.Area] < 1000); % grupos menores a 100 px
    for i=1:size(s,2)              % eliminaci�n de pixeles
        index = ML == s(i);
        Mask(index) = 0;
    end         
    Mask = ~Mask;
    disp([datestr(datetime), ' Fin segmentación ']);
    figure;
    subplot(2,2,1), imagesc(I_rgb), title('Original');  
    borde = ~Mask;
    segmento=double(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    segmento(:,:,1)= segmento(:,:,1).*borde; 
    segmento(:,:,2)= segmento(:,:,2).*borde;
    segmento(:,:,3)= segmento(:,:,3).*borde;
    segmento=uint16(segmento);
    subplot(2,2,2), imagesc(segmento), title('Granos de frijol'); 
    
    borde = Mask;
    seg_t=double(I_rgb);  % Obtenci?n de la imagen para dejar la parte segmentada
    seg_t(:,:,1)= seg_t(:,:,1).*borde; 
    seg_t(:,:,2)= seg_t(:,:,2).*borde;
    seg_t(:,:,3)= seg_t(:,:,3).*borde;
    seg_t=uint16(seg_t);      
    subplot(2,2,3), imagesc(seg_t), title('Fondo'); 
        
    beep;
    choice = questdlg('Continuar con la siguiente población', ...
        'Continuar', 'Si','No','');
 %   choice = 'Si'
 
    % Handle response
    switch choice
        case 'Si'
            disp([choice ' Continuando...'])                        
            %% Guardado histograma 2d de entrenamiento en base de datos
            completo = strcat(populationName,'.mat');
            nombredatos = strcat(imgPath,'Masks/',completo);
            save(nombredatos,'Mask');            
            
        case 'No'
            disp([choice 'Saliendo de la aplicaci�n']);
            close all;
            return;
    end
    close all;
 end
output = 1;



end

