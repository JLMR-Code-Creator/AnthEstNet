function [consolidate, consolidatey] = TrainANN(Y1, ...
                                       PROM_E_HSI, PROM_E_LAB, ...
                                       PROM_V_HSI, PROM_V_LAB, ...
                                       PROM_P_HSI, PROM_P_LAB, ...
                                       indx, filtro, stopSpace, stopOption)
                                   
 colorSpace = {'HSI', 'LAB', 'HSILAB'};
 datas_E = {PROM_E_HSI, PROM_E_LAB, [PROM_E_HSI, PROM_E_LAB]};
 datas_V = {PROM_V_HSI, PROM_V_LAB, [PROM_V_HSI, PROM_V_LAB]};  
 datas_P = {PROM_P_HSI, PROM_P_LAB, [PROM_P_HSI, PROM_P_LAB]};  
      
 consolidate = struct();
 consolidatey = struct();
 for i=1:length(colorSpace)
       container = [];
       yStruct = [];
       spaces = colorSpace{i}; % Obtención del espacio de color
       neurons = [3:40];       
   for j=1:length(neurons)
       if strcmp(filtro, 'Filtro')
          if strcmp(spaces, stopSpace)==0 
             continue;
          end
          if (neurons(j)~=stopOption)
             continue;
          end      
       end
       
           rng('default');
           structName = strcat('DB_',num2str(indx),'_Net', spaces, '_',num2str(neurons(j)));

           inputs_E = datas_E{1, i}; %inputs_E = randn(40, 3);
           b1 = 1;
           b2 = size(inputs_E, 1);

           inputs_V = datas_V{1, i}; %inputs_V = randn(40, 3);
           c1 = b2 + 1;
           c2 = size(inputs_V, 1) + b2;

           inputs_P = datas_P{1, i}; %inputs_P = randn(40, 3);
           d1 = c2 + 1;
           d2 = size(inputs_V, 1) +c2;

           Y = Y1';

           %Y =  randn(120,1)';
           % Create a Fitting Network
           hiddenLayerSize = neurons(j);
           net = fitnet(hiddenLayerSize);


           % Choose Input and Output Pre/Post-Processing Functions      
           net.performFcn = 'mse';
           net.trainParam.showWindow = 0;   % <== This does it

           inputs = [inputs_E; inputs_V; inputs_P]';
           [trainInd, valInd, testInd] = divideind(d2,b1:b2,c1:c2,d1:d2);       
           Y = [Y,Y,Y];       

           % Set up Division of Data for Training, Validation, Testing
            net.divideFcn = 'divideind';
            net.divideParam.trainInd = trainInd;
            net.divideParam.valInd   = valInd;
            net.divideParam.testInd  = testInd;              


           % Train the Network .  
           [net,tr, y] = train(net,inputs,Y)


           y_trOut = y(tr.trainInd); % Vector de observaciones indice de entrenamiento
           y_vOut = y(tr.valInd);    % Vector de observaciones indice de validacion
           y_tsOut = y(tr.testInd);  % Vector de observaciones indice Prueba
           Y_trTarg = Y(tr.trainInd);% Vector de observaciones indice de entrenamiento
           Y_vTarg = Y(tr.valInd);   % Vector de observaciones indice de validacion
           Y_tsTarg = Y(tr.testInd); % Vector de observaciones indice Prueba

           %plotregression(Y_trTarg, y_trOut, 'Entrenamiento', Y_vTarg, y_vOut, 'Validaci�n', Y_tsTarg, y_tsOut, 'Prueba')       
           %[v_error_Porcentual_E, RMSE_E, R2_E]=pperformed(Y_trTarg, y_trOut);
           [RMSE_E, R2_E, MAPE_E, stdMape_E, ~, precision_E, STD_precision_E, ~] = Performance(Y_trTarg, y_trOut)
           %[v_error_Porcentual_V, RMSE_V, R2_V]=pperformed(Y_vTarg, y_vOut);
           [RMSE_V, R2_V, MAPE_V, stdMape_V, ~, precision_V, STD_precision_V, ~] = Performance(Y_vTarg, y_vOut)
           %[v_error_Porcentual_P, RMSE_P, R2_P]=pperformed(Y_tsTarg, y_tsOut);
           [RMSE_P, R2_P, MAPE_P, stdMape_P, ~, precision_P, STD_precision_P, ~] = Performance(Y_tsTarg, y_tsOut)
            %Secci�n de guardado de estructuras e imagenes
            %figure1 = figure;
            %axes1 = axes('Parent',figure1)
            %hold(axes1,'all');
            %plotregression(Y_trTarg, y_trOut, 'Entrenamiento', Y_vTarg, y_vOut, 'Validaci�n', Y_tsTarg, y_tsOut, 'Prueba')        
            %rutaStructure = strcat(pathDB,'/NetsMedian/',structName,'.mat');%Name net       
            %strImg = strcat(pathDB, '/NetsMedian/',structName,'.eps');
            %saveas(figure1, strImg);

            %close all;
            %save(rutaStructure,'net');
            nntraintool('close'); 
            container=[container, MAPE_E, stdMape_E, precision_E, STD_precision_E, RMSE_E, R2_E, MAPE_V, stdMape_V, precision_V, STD_precision_V, RMSE_V, R2_V, MAPE_P, stdMape_P, precision_P, STD_precision_P, RMSE_P, R2_P];
            %y_tsOut = y_tsOut;
            yOut = ordenarVector(Y_tsTarg, y_tsOut);
            yStruct = [yStruct, {yOut}];        
        
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
