function [consolidate, consolidateExplain, consolidatey] = EvaluatingH2DANN(Y1, ...
    HIST_E_HSI, HIST_E_LAB, HIST_V_HSI, HIST_V_LAB,HIST_P_HSI, HIST_P_LAB, ...
    pathDB, indx, nPCA, neurons, filtro, stopSpace, stopOption)
  
 colorSpace = {'PCA_HSI', 'PCA_LAB', 'PCA_HSILAB'};
 [PCA_E_HSI, PCA_V_HSI, PCA_P_HSI, PcD_2D_HSI] = data3C2modelsPlus(HIST_E_HSI, HIST_V_HSI, HIST_P_HSI, nPCA);
 [PCA_E_LAB, PCA_V_LAB, PCA_P_LAB, PcD_2D_LAB] = data3C2modelsPlus(HIST_E_LAB, HIST_V_LAB, HIST_P_LAB, nPCA);
 [PCA_E_HSILAB, PCA_V_HSILAB, PCA_P_HSILAB, PcD_2D_HSILAB] = data3C2modelsPlus([HIST_E_HSI, HIST_E_LAB], [HIST_V_HSI, HIST_V_LAB],[HIST_P_HSI, HIST_P_LAB], nPCA);
 
 
datas_E = {PCA_E_HSI, PCA_E_LAB, ...
    PCA_E_HSILAB};

datas_V = {PCA_V_HSI, PCA_V_LAB, ...
    PCA_V_HSILAB};

datas_P = {PCA_P_HSI, PCA_P_LAB, ...
    PCA_P_HSILAB};

    PcD_2D_HSI =  sum(PcD_2D_HSI);
    PcD_2D_HSI = [PcD_2D_HSI, sum(PcD_2D_HSI)];
    %PcD_2D_HSI = string(PcD_2D_HSI);
    PcD_2D_LAB = sum(PcD_2D_LAB);
    PcD_2D_LAB = [PcD_2D_LAB, sum(PcD_2D_LAB)];
    %PcD_2D_LAB = string(PcD_2D_LAB);  
    PcD_2D_HSILAB = sum(PcD_2D_HSILAB);
    PcD_2D_HSILAB = [PcD_2D_HSILAB, sum(PcD_2D_HSILAB)];

    explain = {PcD_2D_HSI, PcD_2D_LAB, PcD_2D_HSILAB};
      
 consolidate = struct();
consolidateExplain = struct();
consolidatey = struct();
 
 for i=1:length(colorSpace)
       container = [];
       yStruct = [];
       spaces = colorSpace{i}; %Obtenci�n del espacio de color
       
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
           structName = strcat('DB2D_',num2str(indx),'_', spaces,'_','Net_',num2str(nPCA),'_',num2str(neurons(j)),'_', '1');

           inputs_E = datas_E{1, i};
           %inputs_E = randn(40, 3);
           b1 = 1
           b2 = size(inputs_E, 1);

           inputs_V = datas_V{1, i};
           %inputs_V = randn(40, 3);
           c1 = b2 + 1
           c2 = size(inputs_V, 1) + b2;

           inputs_P = datas_P{1, i};
           %inputs_P = randn(40, 3);
           d1 = c2 + 1
           d2 = size(inputs_V, 1) +c2;
           
           Y = Y1';

           %Y =  randn(120,1)';
           % Create a Fitting Network
           hiddenLayerSize = neurons(j);
           net = fitnet([hiddenLayerSize]);

           net.trainParam.epochs=1500;
           % Choose Input and Output Pre/Post-Processing Functions      
           net.performFcn = 'mse';
           net.trainParam.showWindow = 0;   % <== This does it

           inputs = [inputs_E; inputs_V; inputs_P]';
           [trainInd,valInd,testInd] = divideind(d2,b1:b2,c1:c2,d1:d2);                  
           Y = [Y,Y,Y];       

           % Set up Division of Data for Training, Validation, Testing
            net.divideFcn = 'divideind';
            net.divideParam.trainInd = trainInd;
            net.divideParam.valInd   = valInd;
            net.divideParam.testInd  = testInd;              


           % Train the Network .  
           [net,tr, y] = train(net,inputs,Y);


           y_trOut = y(tr.trainInd); % Vector de observaciones �ndice
           y_vOut = y(tr.valInd);    % Vector de observaciones �ndice
           y_tsOut = y(tr.testInd);  % Vector de observaciones �ndice Prueba
           Y_trTarg = Y(tr.trainInd);% Vector de observaciones �ndice
           Y_vTarg = Y(tr.valInd);   % Vector de observaciones �ndice
           Y_tsTarg = Y(tr.testInd); % Vector de observaciones �ndice Prueba

           %plotregression(Y_trTarg, y_trOut, 'Entrenamiento', Y_vTarg, y_vOut, 'Validaci�n', Y_tsTarg, y_tsOut, 'Prueba')       

%            RMSE = rmse(Y_tsTarg,y_tsOut);
%            RSS = sum((Y_tsTarg - y_tsOut).^2);
%            TSS = sum((Y_tsTarg - mean(Y_tsTarg)).^2);
%            R2 = (TSS-RSS)/TSS
%            YInc=Y_tsTarg+1;
%            yInc2=y_tsOut+1;
%            % Error porcentual
%            v_error_Porcentual=mean((abs(YInc-yInc2)./YInc)*100); 
           
           %[v_error_Porcentual_E1, RMSE_E1, R2_E1]=pperformed(Y_trTarg, y_trOut);
           [RMSE_E, R2_E, MAPE_E, stdMape_E, ~, precision_E, STD_precision_E, ~] = Performance(Y_trTarg, y_trOut);
           %[v_error_Porcentual_V1, RMSE_V1, R2_V1]=pperformed(Y_vTarg, y_vOut);
           [RMSE_V, R2_V, MAPE_V, stdMape_V, ~, precision_V, STD_precision_V, ~] = Performance(Y_vTarg, y_vOut);           
           %[v_error_Porcentual_P1, RMSE_P1, R2_P1]=pperformed(Y_tsTarg, y_tsOut);
           [RMSE_P, R2_P, MAPE_P, stdMape_P, MAPE_Vector_P, precision_P, STD_precision_P, PRE_Vector_P] = Performance(Y_tsTarg, y_tsOut);
           if indx == 37
            [clase, antocianinas] = Determinaciones(40);     
            Y = mean(antocianinas')';
            [B,idx] = sort(Y,'ascend');          
            color_ = string(clase(:,2));
            colorVal = replace(color_, 'B', '(White)');    % Blanco White
            colorVal = replace(colorVal, 'A', '(Yellow)'); % Amarillo Yellow
            colorVal = replace(colorVal, 'N', '(Black)');  % Negro Black
            colorVal = replace(colorVal, 'C', '(Brown)');  % Negro Black
            colorVal = replace(colorVal, 'R', '(Red)');    % Negro Black
            labelPob=strcat(string(clase(:,1)),'-',colorVal,'');   
            sortLabelPop = labelPob(idx);
            MAPE_Vector_P40 = reshape(MAPE_Vector_P,[4, 40])';
            SORT_MAPE = MAPE_Vector_P40(idx, :);
            Final_Order = SORT_MAPE';   
            plotAchieved(Final_Order, sortLabelPop, 'MAPE (1 Executions) PCA of Histogram L*a*b* and NN','Best result', 'Bean landraces', 'Error');
            PRE_Vector_P40 = reshape(PRE_Vector_P,[4, 40])';
            SORT_PRE = PRE_Vector_P40(idx, :);
            Final_Order_PRE = SORT_PRE';

            plotAchieved(Final_Order_PRE, sortLabelPop, 'PCA of histograms CIE L*a*b* and NN', 'Best result', 'Bean landraces', 'Precision');
            %plotAchieved(Final_Order_PRE, sortLabelPop, 'PCA de histogramas HSI y redes neuronales ', 'Mejor resultado', 'Poblaciones de frijol', 'Escala');
             Estimations = reshape(y_tsOut, [4, 40])';
             PCA_HSI = Estimations(idx, :);
             PCA_LAB_NN = PCA_HSI';

           end

           container=[container, MAPE_E, stdMape_E, precision_E, STD_precision_E, RMSE_E, R2_E, MAPE_V, stdMape_V, precision_V, STD_precision_V, RMSE_V, R2_V, MAPE_P, stdMape_P, precision_P, STD_precision_P, RMSE_P, R2_P];
            % y_tsOut = y_tsOut';

            %ordenado = ordenarVector(Y_trTarg, y_tsOut);
            yStruct = [yStruct, {y_tsOut}];
   end
   
   if strcmp(filtro, 'Filtro')
      if strcmp(spaces, stopSpace)==0 
         continue;
      end      
   end      
   
   consolidate.(spaces) = container;
   consolidateExplain.(spaces) = explain{i};
   consolidatey.(spaces) = yStruct;   
 end

end
function plotAchieved(MAPE, labelPob, lbltitle, lblsubtitle, xlbl, ylbl)
   figure1 = figure('DefaultAxesFontSize',20);
   figure1.WindowState = 'maximized';
   axes1 = axes('Parent',figure1);
   hold(axes1,'all');
   hold on
     boxplot(MAPE,'Labels',labelPob) 
     set(gca,'FontSize',12,'fontweight','bold','XTickLabelRotation',90)
     grid on
     xlabel(xlbl, 'FontSize', 13),
     ylabel(ylbl, 'FontSize', 13),
     title(lbltitle);
     subtitle(lblsubtitle);
     hold off
end