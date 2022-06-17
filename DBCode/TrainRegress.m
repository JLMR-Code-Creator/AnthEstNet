function [consolidate, consolidatey] = TrainRegress(Y1, ...
          PROM_E_HSI, PROM_E_LAB, PROM_P_HSI, PROM_P_LAB, ...
          filtro, stopSpace, stopOption)

colorSpace = {'HSI', 'LAB', 'HSILAB'};
datas_E = {PROM_E_HSI, PROM_E_LAB, ...
          [PROM_E_HSI, PROM_E_LAB]};
datas_V = {PROM_P_HSI, PROM_P_LAB, ...
          [PROM_P_HSI, PROM_P_LAB]};
consolidate = struct();
consolidatey = struct();
for i=1:length(colorSpace)
    container = [];
    yStruct = [];
    spaces = colorSpace{i};
    options = {'linear' 'interactions' 'purequadratic' 'quadratic'};
    
    for j=1:length(options)
        if strcmp(filtro, 'Filtro')
           if strcmp(spaces, stopSpace)==0
              continue;
           end
           if strcmp(options{j}, stopOption) == 0
              continue;
           end               
        end
        
        rng('default');
        %structName = strcat('DB_',num2str(indx),'_Regress', spaces, '_',options{j});        
        inputs_E = datas_E{1, i};
        %inputs_E = randn(40, 3);        
        inputs_V = datas_V{1, i};
        %inputs_V = randn(40, 3);
        Y = Y1;        
        % Conjunto de entrenamiento
        designM = inputs_E;
        designM(:,end+1)=1;
        
        mdlRegress = fitlm(designM, Y, options{j}, 'RobustOpts', 'off'); % 'linear' 'interactions' 'purequadratic' 'quadratic'
        
        % Conjunto de validaci�n
        designM2 = inputs_V;
        designM2(:,end+1)=1;
        
        y_teOut = predict(mdlRegress,designM);
        [MAPE_E, RMSE_E, R2_E, stdMape_E,~, precision_E, STD_precision_E, ~] = PerformanceRegresion(Y, y_teOut, mdlRegress.NumEstimatedCoefficients);
        % Prueba del modelo
        y_tsOut = predict(mdlRegress,designM2);
        [MAPE_P, RMSE_P, R2_P, stdMape_P, ~, precision_P, STD_precision_P, ~] = PerformanceRegresion(Y, y_tsOut, mdlRegress.NumEstimatedCoefficients);

        %Secci�n de guardado de estructuras e imagenes
        %figure1 = figure;
        %axes1 = axes('Parent',figure1)
        %hold(axes1,'all');
        %plotregression(Y, y_trOut, 'Entrenamiento',  Y, y_tsOut, 'Prueba')
        %rutaStructure = strcat(pathDB,'Regress/',structName,'.mat');%Name net
        %strImg = strcat(pathDB, 'Regress/',structName,'.eps');
        %saveas(figure1, strImg);
        
        %close all;
        %save(rutaStructure,'mdlRegress');        
        container=[container, MAPE_E, stdMape_E, precision_E, STD_precision_E, RMSE_E, R2_E, MAPE_P, stdMape_P, precision_P, STD_precision_P, RMSE_P, R2_P ];
        %y = y_tsOut';
        y = ordenarVector(Y, y_tsOut);
        yStruct = [yStruct, {y}];
    end
        if strcmp(filtro, 'Filtro')
           if strcmp(spaces, stopSpace)==0
              continue;
           end             
        end    
    consolidate.(spaces) = container;
    consolidatey.(spaces) = yStruct;
end

end
