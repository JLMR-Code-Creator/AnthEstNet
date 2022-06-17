function [output] = Morpho_ANN(pathDB, file, type, option, nPCA, neurons, dirOut, ColorType, filtro, stopSpace, stopOption)

%option: 1 promedio de color; 2 histogramas 2D, 3 histogramas 3D

dbPopulations = dir(strcat(pathDB,file)); % Cargar todas las muestras de entrenamiento 
N=length(dbPopulations);
finalDir = strcat(pathDB, dirOut);
 if ~exist('',finalDir)
     mkdir(finalDir);
 end 

net_C_ColorSpaces = [];
pca_explain_ColorSpace = [];
regress_C_ColorSpacesy = [];
%yy = [];

 for i = 1 : N
    dbfile = dbPopulations(i).name;       % Nombre de la db 
    disp(dbfile);
    load(strcat(pathDB,dbfile),'-mat');
    if (option == 1) % averages predefined neurons
       [consolidate, consolidatey] = TrainANN(YTrainLAB, ...
                                     AVG_E_HSI, AVG_E_LAB, ...
                                     AVG_V_HSI, AVG_V_LAB, ...
                                     AVG_P_HSI, AVG_P_LAB, ...
                                     i, filtro, stopSpace, stopOption);
          net_C_ColorSpaces = [net_C_ColorSpaces; consolidate];
          regress_C_ColorSpacesy = [regress_C_ColorSpacesy; consolidatey]; 
    elseif(option==2)
        if i<6
            continue
        end
        [HIST2D_E_HSI, HIST2D_E_LAB, ...
         HIST2D_V_HSI, HIST2D_V_LAB, ...
         HIST2D_P_HSI, HIST2D_P_LAB ] = ProcessingHist2DData(...
                                    XTrainHSI, XValidationHSI, XTestHSI,...
                                    XTrainLAB, XValidationLAB, XTestLAB);
        [consolidate,consolidateExplain, consolidatey] = EvaluatingH2DANN(YTrainLAB, ...
        HIST2D_E_HSI, HIST2D_E_LAB, ...
        HIST2D_V_HSI, HIST2D_V_LAB, ...
        HIST2D_P_HSI, HIST2D_P_LAB, ...
        pathDB, i, nPCA, neurons, filtro, stopSpace, stopOption); 

        net_C_ColorSpaces = [net_C_ColorSpaces; consolidate];    
        pca_explain_ColorSpace = [pca_explain_ColorSpace; consolidateExplain];
        regress_C_ColorSpacesy = [regress_C_ColorSpacesy; consolidatey]; 
    end
 end % end for N databases
  
     if strcmp(filtro, 'Filtro')
         if (option == 1)
             
             labelValue = {'MAPE_E', 'STD_E','PRECISION_E', 'STD_PRE_E','RMSE_E', 'R2_E','MAPE_V', 'STD_V','PRECISION_V', 'STD_PRE_V','RMSE_V', 'R2_V', 'MAPE_P', 'STD_P','PRECISION_P', 'STD_PRE_P','RMSE_P', 'R2_P'};
             T = struct2table(net_C_ColorSpaces);
             T = table2array(T);
             dataColorSpace = T;
             id = [];
             for j=1:size(dataColorSpace, 1)
                 id = [id;{j}];
             end
             id = [id; {'Mean'}; {'std'}];
             
             dataColorSpace = [dataColorSpace; mean(dataColorSpace);std(dataColorSpace);];
             dataColorSpace = [id, num2cell(dataColorSpace)];
             
             labelVect = [];
             labelTitle = [];
             %structure = {[stopSpace,':',stopOption]};
             structure = {[num2str(size(stopSpace, 2)),':',num2str(stopOption),':', '1']};
             structure = [structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure];
             labelTitle = [labelTitle, structure];
             labelVect = [labelVect, labelValue];
             labelTitle = [{'Modelo'},labelTitle ];
             labelVect = [{'Num'}, labelVect];
             seccionReport = [labelTitle;labelVect; dataColorSpace];
             Concentrado = table(seccionReport)
             filename = strcat(pathDB, dirOut,'/Average_',stopSpace,'_',int2str(stopOption),'_ANN.xlsx');
             writetable(Concentrado,filename,'Sheet',stopSpace, 'WriteVariableNames', false);             
             %lsbel = {[num2str(size(stopSpace, 2)),':',num2str(stopOption),':', '1']};
             %ProcesaCell(pathDB, regress_C_ColorSpacesy, antocianinas, pob, color, stopSpace, lsbel)
         else
             T = struct2table(net_C_ColorSpaces)
             T_Explain = struct2table(pca_explain_ColorSpace);
             
             label = strcat('Net', stopSpace);
             T = table2array(T);
             dataColorSpace = T;
             T_Explain = table2array(T_Explain);
             dataColorSpaceExp = T_Explain;
             id = [];
             
             for j=1:size(dataColorSpace, 1)
                 id = [id;{j}];
             end
             id = [id; {'Mean'}; {'std'}];
             
             dataColorSpace = [dataColorSpace; mean(dataColorSpace);std(dataColorSpace);];
             dataColorSpaceExp = [dataColorSpaceExp; mean(dataColorSpaceExp);  std(dataColorSpaceExp)];
             dataColorSpace = [id, num2cell(dataColorSpace),  num2cell(dataColorSpaceExp)];
             
             labelVect = [];
             labelTitle = [];             
             labelValue = {'MAPE_E', 'STD_E','PRECISION_E', 'STD_PRE_E','RMSE_E', 'R2_E','MAPE_V', 'STD_V','PRECISION_V', 'STD_PRE_V','RMSE_V', 'R2_V', 'MAPE_P', 'STD_P','PRECISION_P', 'STD_PRE_P','RMSE_P', 'R2_P'};             
             %neurons = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
             structure = {[num2str(nPCA),':',num2str(stopOption),':', '1']};
             structure = [structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure];
             labelTitle = [labelTitle, structure];
             labelVect = [labelVect, labelValue];
             
             for j=1:nPCA
                 labelTitle = [labelTitle, 'PCA'];
                 labelVect = [labelVect, int2str(j)];
             end
             labelTitle = [labelTitle, 'Total_PCA'];
             labelVect = [labelVect, '-'];
             labelTitle = [{'Estructura'},labelTitle ];
             labelVect = [{'Núm'}, labelVect];
             seccionReport = [labelTitle;labelVect; dataColorSpace];
             Concentrado = table(seccionReport);
             %filename = strcat(pathDB, dirOut,'/H2D_',stopSpace,'_',int2str(stopOption),'_ANN.xlsx');
             %writetable(Concentrado,filename,'Sheet',stopSpace, 'WriteVariableNames', false);                          
             %lsbel = {[num2str(nPCA),':',num2str(stopOption),':', '1']};
             %GenerateDataReport(pathDB, regress_C_ColorSpacesy, antocianinas, pob, color, nPCA, pca_explain_ColorSpace, stopSpace, stopOption, lsbel)
             PlotMAPE(regress_C_ColorSpacesy,YTrainLAB, CTrainLandraces, CTrainColor, 'PCA_LAB')
         end
     else        
       Generate_DataReport_ANN(pathDB, net_C_ColorSpaces, option, nPCA, neurons, pca_explain_ColorSpace, regress_C_ColorSpacesy, dirOut);
     end

%    
output = 0;
end

function [HIST2D_E_HSI, HIST2D_E_LAB, ...
    HIST2D_V_HSI, HIST2D_V_LAB, ...
    HIST2D_P_HSI, HIST2D_P_LAB, ...
    antocianinas, pob, color] = ProcessingHist2DData(...
                                XTrainHSI, XValidationHSI, XTestHSI,...
                                XTrainLAB, XValidationLAB, XTestLAB)

HIST2D_E_HSI = [];  HIST2D_E_LAB = [];
HIST2D_V_HSI = [];  HIST2D_V_LAB = [];
HIST2D_P_HSI = [];  HIST2D_P_LAB = [];
antocianinas = []; pob = []; color = [];

for j = 1 : size(XTrainHSI, 4)

    H2D_E_HSI = XTrainHSI(:,:,j);
    H2D_E_LAB = XTrainLAB(:,:,j);
    VEC_E_HS = reshape(H2D_E_HSI, size(H2D_E_HSI,1)*size(H2D_E_HSI,2), 1);
    VEC_E_AB = reshape(H2D_E_LAB, size(H2D_E_LAB,1)*size(H2D_E_LAB,2), 1);    
    HIST2D_E_HSI = [HIST2D_E_HSI;VEC_E_HS'];
    HIST2D_E_LAB = [HIST2D_E_LAB;VEC_E_AB'];
    
    H2D_V_HSI = XValidationHSI(:,:,j);
    H2D_V_LAB = XValidationLAB(:,:,j);
    VEC_V_HS = reshape(H2D_V_HSI, size(H2D_V_HSI,1)*size(H2D_V_HSI,2), 1);
    VEC_V_AB = reshape(H2D_V_LAB, size(H2D_V_LAB,1)*size(H2D_V_LAB,2), 1);
    HIST2D_V_HSI = [HIST2D_V_HSI;VEC_V_HS'];
    HIST2D_V_LAB = [HIST2D_V_LAB;VEC_V_AB'];    
    
    H2D_P_HSI = XTestHSI(:,:,j);
    H2D_P_LAB = XTestLAB(:,:,j);
    VEC_P_HS = reshape(H2D_P_HSI, size(H2D_P_HSI,1)*size(H2D_P_HSI,2), 1);
    VEC_P_AB = reshape(H2D_P_LAB, size(H2D_P_LAB,1)*size(H2D_P_LAB,2), 1);    
    HIST2D_P_HSI = [HIST2D_P_HSI;VEC_P_HS'];
    HIST2D_P_LAB = [HIST2D_P_LAB;VEC_P_AB'];
end

end


function  ProcesaCell(pathDB, datay, antocianinas, pob, color, stopSpace, stopOption)
    Ty = struct2table(datay);
    label = strcat(stopSpace, ' - ',stopOption);
    Ty = table2array(Ty);
    yVec = cell2mat(Ty);
    Ploty(pathDB, yVec, antocianinas, pob, color, label, -1);
end

function  GenerateDataReport(pathDB, datay, antocianinas, pob, color, nPCA, pca_explain_ColorSpace, stopSpace, stopOption, lbl)
  
    Ty = struct2table(datay);
  for i=1:size(Ty, 2)      
      label = strcat(num2str(nPCA), ' - ',stopSpace, ' - ',num2str(stopOption), '-', lbl);
      Ty = table2array(Ty);
      yVec = cell2mat(Ty);
      Ploty(pathDB, yVec, antocianinas, pob, color, label, min(min(yVec)))
  end 
end
function Ploty(pathDB, data, antocianinas, pob, color, structName, aumento)
%%
     Y = mean(antocianinas')';
     figure1 = figure('DefaultAxesFontSize',12);
     figure1.WindowState = 'maximized';
     axes1 = axes('Parent',figure1)
     hold(axes1,'all');
    
     %aumento = round(min(min(data)))-2;
     aumento = -1;
     
     
     labelPob=strcat(pob,'-',color,'');
     [YA,I] = sort(Y);
     plot(Y(I))
     hold on,
     plot(Y(I),'ob')
     text(1:length(Y),zeros(1,length(Y))+aumento,labelPob(I),'VerticalAlignment','middle','HorizontalAlignment','right', 'FontSize', 12, 'rotation',90);
     plot(data','*r')
     title(structName);
     grid on
     grid minor
     ylabel('Anthocyanins','FontSize',12);
     
     lgd = legend('','Real Anthocyanins',' Estimated anthocyanins');
     lgd.FontSize = 12;
     lgd.FontWeight = 'bold';
     %pause(1);
      %  strImg = strcat(pathDB, '/Nets/',structName,'.eps');
      %  saveas(figure1, strImg,'epsc');
     %close all;
end
