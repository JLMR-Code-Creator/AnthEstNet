function [output] = Morpho_Regression(pathDB, file, type,  option, nPCA, dirOut, ColorType, filtro, stopSpace, stopOption)

    dbPopulations = dir(strcat(pathDB,file)); % Cargar todas las muestras de entrenamiento
    N=length(dbPopulations);

    finalDir = strcat(pathDB, dirOut);
    if ~exist('',finalDir)
        mkdir(finalDir);
    end
    regress_C_ColorSpaces = [];
    pca_explain_ColorSpace = [];
    regress_C_ColorSpacesy = [];

    for i = 1 : N
        dbfile = dbPopulations(i).name;       % Nombre de la db
        disp(dbfile);
        load(strcat(pathDB,dbfile),'-mat');
        if (option == 1) % averages
            [consolidate, consolidatey] = TrainRegress(YTestLAB, ...
            REG_AVG_E_HSI, REG_AVG_E_LAB, REG_AVG_P_HSI, REG_AVG_P_LAB, ...
            filtro, stopSpace, stopOption);
            regress_C_ColorSpaces = [regress_C_ColorSpaces; consolidate];
            regress_C_ColorSpacesy = [regress_C_ColorSpacesy; consolidatey];               
        elseif(option==2) % for histograms 2d
            [HIST_E_HSI, HIST_E_LAB, ...
                     HIST_P_HSI, HIST_P_LAB] = ProcessingHist2DData(...
                REG_H2D_E_HSI, REG_H2D_P_HSI, REG_H2D_E_LAB, REG_H2D_P_LAB);
            [consolidate, consolidateExplain, consolidatey] = EvaluatingH2DRegress(YTestLAB, ...
              HIST_E_HSI, HIST_E_LAB, HIST_P_HSI, HIST_P_LAB, ...
              pathDB, i, type, nPCA, option, filtro, stopSpace, stopOption);
              regress_C_ColorSpaces = [regress_C_ColorSpaces; consolidate];
              pca_explain_ColorSpace = [pca_explain_ColorSpace; consolidateExplain];
              regress_C_ColorSpacesy = [regress_C_ColorSpacesy; consolidatey];               
         end
    end % end for N databases

     if strcmp(filtro, 'Filtro')
         if (option == 1)
             labelValue = {'MAPE_E', 'Std_E', 'PRECISION_E', 'STD_PRE_E', 'RMSE_E', 'R2_E','MAPE_P', 'Std_P', 'PRECISION_P', 'STD_PRE_P', 'RMSE_P', 'R2_P'};
             T = struct2table(regress_C_ColorSpaces);
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
             structure = {[stopSpace,':',stopOption]};
             structure = [structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure, structure];
             labelTitle = [labelTitle, structure];
             labelVect = [labelVect, labelValue];
             labelTitle = [{'Modelo'},labelTitle ];
             labelVect = [{'Num'}, labelVect];
             seccionReport = [labelTitle;labelVect; dataColorSpace];
             Concentrado = table(seccionReport);
             filename = strcat(pathDB, dirOut,'/AVG_Regress_Result.xlsx');
             writetable(Concentrado,filename,'Sheet',stopSpace, 'WriteVariableNames', false);
             %ProcesaCell(pathDB, regress_C_ColorSpacesy, antocianinas, pob, color, stopSpace, stopOption)
         else
             colorSpace = {'PCA_HSI', 'PCA_LAB', 'PCA_HSILAB'};
             labelValue = {'MAPE_E', 'Std_E', 'PRECISION_E', 'STD_PRE_E', 'RMSE_E', 'R2_E','MAPE_P', 'Std_P', 'PRECISION_P', 'STD_PRE_P', 'RMSE_P', 'R2_P'};
             T = struct2table(regress_C_ColorSpaces);
             T_Explain = struct2table(pca_explain_ColorSpace);
             
             label = strcat('Regress_', stopSpace);
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
             
             
             structure = {[stopSpace,':',stopOption]};
             structure = [structure, structure, structure,structure, structure, structure, structure, structure, structure, structure, structure, structure];
             labelTitle = [labelTitle, structure];
             labelVect = [labelVect, labelValue];
             
             for j=1:nPCA
                 labelTitle = [labelTitle, 'PCA'];
                 labelVect = [labelVect, int2str(j)];
             end
             labelTitle = [labelTitle, 'Total_PCA'];
             labelVect = [labelVect, '-'];
             
             labelTitle = [{'Modelo'},labelTitle ];
             labelVect = [{'Núm'}, labelVect];
             seccionReport = [labelTitle;labelVect; dataColorSpace]
             
             Concentrado = table(seccionReport);
             filename = strcat(pathDB, dirOut,'/',int2str(nPCA),'_',stopSpace,'_','His2D_Regress_Result.xlsx');
             writetable(Concentrado,filename,'Sheet',stopSpace, 'WriteVariableNames', false);
             %GenerateDataReport(pathDB, regress_C_ColorSpacesy, antocianinas, pob, color, nPCA, pca_explain_ColorSpace, stopSpace, stopOption)
         end
     else               
       Generate_DataReport_Regress(pathDB, regress_C_ColorSpaces, option, nPCA, pca_explain_ColorSpace, dirOut)
     end
    
    output = 0;


end % end function

function [HIST2D_E_HSI, HIST2D_E_LAB, ...
    HIST2D_P_HSI, HIST2D_P_LAB] = ProcessingHist2DData(...
    REG_H2D_E_HSI, REG_H2D_P_HSI, REG_H2D_E_LAB, REG_H2D_P_LAB)

HIST2D_E_HSI = [];  HIST2D_E_LAB = [];
HIST2D_P_HSI = [];  HIST2D_P_LAB = [];

for j = 1 : size(REG_H2D_E_HSI, 4)
    H2D_E_HSI = REG_H2D_E_HSI(:,:,j);
    H2D_E_LAB = REG_H2D_E_LAB(:,:,j);
    VEC_E_HS = reshape(H2D_E_HSI, size(H2D_E_HSI,1)*size(H2D_E_HSI,2), 1);
    VEC_E_AB = reshape(H2D_E_LAB, size(H2D_E_LAB,1)*size(H2D_E_LAB,2), 1);
    HIST2D_E_HSI = [HIST2D_E_HSI;VEC_E_HS'];
    HIST2D_E_LAB = [HIST2D_E_LAB;VEC_E_AB'];
    
    H2D_E_HSI = REG_H2D_P_HSI(:,:,j);
    H2D_E_LAB = REG_H2D_P_LAB(:,:,j);
    VEC_P_HS = reshape(H2D_E_HSI, size(H2D_E_HSI,1)*size(H2D_E_HSI,2), 1);
    VEC_P_AB = reshape(H2D_E_LAB, size(H2D_E_LAB,1)*size(H2D_E_LAB,2), 1);
    HIST2D_P_HSI = [HIST2D_P_HSI;VEC_P_HS'];
    HIST2D_P_LAB = [HIST2D_P_LAB;VEC_P_AB'];
end
end


function [consolidate, consolidateExplain, consolidatey] = EvaluatingH2DRegress(Y1, ...
    HIST_E_HSI, HIST_E_LAB, HIST_P_HSI, HIST_P_LAB, ...
    pathDB, indx, type, nPCA, option, filtro, stopSpace, stopOption)

    colorSpace = {'PCA_HSI', 'PCA_LAB', 'PCA_HSILAB'};

    [PCA_E_HSI, PCA_P_HSI, PcD_2D_HSI] = data2modelsPlus(HIST_E_HSI, HIST_P_HSI, nPCA);
    [PCA_E_LAB, PCA_P_LAB, PcD_2D_LAB] = data2modelsPlus(HIST_E_LAB, HIST_P_LAB, nPCA);
    [PCA_E_HSILAB, PCA_P_HSILAB, PcD_2D_HSILAB] = data2modelsPlus([HIST_E_HSI, HIST_E_LAB], [HIST_P_HSI, HIST_P_LAB], nPCA);

    datas_E = {PCA_E_HSI, PCA_E_LAB, PCA_E_HSILAB};
    datas_P = {PCA_P_HSI, PCA_P_LAB, PCA_P_HSILAB};

    PcD_2D_HSI =  sum(PcD_2D_HSI);
    PcD_2D_HSI = [PcD_2D_HSI, sum(PcD_2D_HSI)];
    
    PcD_2D_LAB = sum(PcD_2D_LAB);
    PcD_2D_LAB = [PcD_2D_LAB, sum(PcD_2D_LAB)];
    
    PcD_2D_HSILAB = sum(PcD_2D_HSILAB);
    PcD_2D_HSILAB = [PcD_2D_HSILAB, sum(PcD_2D_HSILAB)];

    explain = {PcD_2D_HSI, PcD_2D_LAB, PcD_2D_HSILAB};

   [consolidate, consolidateExplain, consolidatey] ...
         = trainAndTest(pathDB, colorSpace, datas_E, datas_P, Y1, explain, indx, nPCA, option, filtro, stopSpace, stopOption);    
end

function  ProcesaCell(pathDB, datay, antocianinas, pob, color, stopSpace, stopOption)
    Ty = struct2table(datay);
    label = strcat(stopSpace, ' - ',stopOption);
    Ty = table2array(Ty);
    yVec = cell2mat(Ty);
    Ploty(pathDB, yVec, antocianinas, pob, color, label, 0);
end


function  GenerateDataReport(pathDB, datay, antocianinas, pob, color, nPCA, pca_explain_ColorSpace, stopSpace, stopOption)
  
    Ty = struct2table(datay);
  for i=1:size(Ty, 2)      
      label = strcat(num2str(nPCA), ' - ',stopSpace, ' - ',stopOption);
      Ty = table2array(Ty);
      yVec = cell2mat(Ty);
      Ploty(pathDB, yVec, antocianinas, pob, color, label, 0)
  end 
end


function Ploty(pathDB, data, antocianinas, pob, color, structName, aumento)
%%
     Y = mean(antocianinas')';
     figure1 = figure('DefaultAxesFontSize',12);
     figure1.WindowState = 'maximized';
     axes1 = axes('Parent',figure1)
     hold(axes1,'all');
    
     aumento = round(min(min(data))) - 1;
     
     
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



