function REGION = ColorRegionGrowingLab(I, Lab ,maxdist, x,y)
% ColorRegionGrowing Segmentaci�n por crecimiento de regi�n con pixel
% semilla.
% Entrada: 
%         I: matriz de nxmxz correspondiente a una imagen RGB.
%         x: coordenada de x del pixel semilla
%         y: coordenada de y del pixel semilla
%         maxdist: m�xima distancia entre pixel semilla y pixel vecino
% Salida:
%        REGION:matriz binaria de nxm que corresponde a la mascara de
%        segmentaci�n.

%    h = fspecial('gaussian',[3 3]); % matriz peque�a para suavizado
%    I = imfilter(I, h); % Aplicaci�n de suavizado
    I = im2double(I);   % valores de la imagen al tipo double
    % pedir coordenadas de pixel semilla
    if(exist('y','var')==0) % petici�n de coordenadas si no fueron especificadas.
        %
        h1 = figure('name', 'SEGMENTACION','NumberTitle','off'), imshow(I,[]), [y,x]=getpts(h1); 
        y=round(y(1)); 
        x=round(x(1)); 
    end

    %Lab = rgb2lab(I);  % conversi?n al espacio de color CIE L*A*B*
    SEED = Lab(x,y,:); % Coordenadas para la obtenci�n del pixel semilla
    w1 = 0;          % Pesos 
    w2 = 0;
    w3 = 0;

    if(maxdist==0) % si distancia no es especificada en la funci�n
           if((SEED(1,1,1) > 29 && SEED(1,1,1) < 85) && ...     % l*
              (SEED(1,1,2) > -5.20 && SEED(1,1,2) < 15) && ...  % a*
              (SEED(1,1,3) > -17.58 && SEED(1,1,3) < 8))        % b*
                   if(maxdist==0)
                       maxdist = 20; % Fondo blanco poblaciones de color negro
                   end
                    w1 = 0.2422;
                    w2 = 1.3760;
                    w3 = 0.8780;
           elseif((SEED(1,1,1) >   0 && SEED(1,1,1) <  43) && ... % l*
                  (SEED(1,1,2) > - 7 && SEED(1,1,2) <  12) && ... % a*
                  (SEED(1,1,3) > - 10 && SEED(1,1,3) < 29))       % b*
                   if(maxdist==0)
                       maxdist = 25; %Fondo negro poblaciones de color blanco
                   end
                    w1 = 0.6264;
                    w2 = 1.3282;
                    w3 = 0.9493;
            elseif((SEED(1,1,1) >   0 && SEED(1,1,1) <   90) && ... % l*
                   (SEED(1,1,2) > - 130 && SEED(1,1,2) <    5) && ... % a*
                   (SEED(1,1,3) > - 130 && SEED(1,1,3) <   9))        % b*
                    if(maxdist==0)
                        maxdist = 20; % Fondo azul claro poblaciones de varios colores
                    end
                    w1 = 0.3241; 
                    w2 = 1.1672; 
                    w3 = 0.8521; 
                    
           elseif((SEED(1,1,1) >   0 && SEED(1,1,1) <   94) && ... % l*
                   (SEED(1,1,2) > - 26 && SEED(1,1,2) <   12) && ... % a*
                   (SEED(1,1,3) > - 26 && SEED(1,1,3) <   29))        % b*
                    if(maxdist==0)
                       maxdist = 20; % Fondo azul claro poblaciones homogeneas
                    end
                    w1 = 0.1934; 
                    w2 = 0.9295; 
                    w3 = 1.2818;                    
           else
               h = msgbox('Intente con nueva semilla pixel alejada del grano de frijol y el fondo a usar para contrastar debe ser negro, blanco o azul claro ','Nuevo intento');
               close all;
               return;
           end

    end
    Isizes = size(I); % Rangos de dimensi?n de imagen
    neigb = [-1 0; 1 0; 0 -1;0 1; -1 1;1 1;-1 -1;1 -1]; % 8 vecinos
    REGION = zeros(size(I,1), size(I,2)); % Salida
    REGION(x,y) = 1;
    Vecinos_Pendientes = [];
    Vecinos_Pendientes = [Vecinos_Pendientes;x,y];
    while(~isempty(Vecinos_Pendientes))
        x = Vecinos_Pendientes(1,1);% valor 1 de la posici�n 1
        y = Vecinos_Pendientes(1,2);% valor 2 de la posici�n 2
        % Recorrer los pixeles vecinos
        for j=1:size(neigb,1) % Recorrer las coordenas de los 8 vecinos
            % Calcula la coordenada del pixel vecino
            xn = x + neigb(j,1); 
            yn = y + neigb(j,2);
            % Limites de la imagen
            limite = (xn >= 1) && (xn <= Isizes(1)) && (yn >= 1) && (yn <= Isizes(2));

            % Agrega vecino sin sobrepasar el l�mite
            if (limite && ( REGION(xn,yn) == 0))                  
               D_l = (Lab(xn,yn,1) - SEED(1,1,1)).^2;
               D_a = (Lab(xn,yn,2) - SEED(1,1,2)).^2;
               D_b = (Lab(xn,yn,3) - SEED(1,1,3)).^2;
               ac = w1*D_l + w2*D_a + w3*D_b;
               ac = D_l + D_a + D_b;
               ac = double(ac);      
               DIST = sqrt(ac);
               if (DIST < maxdist)% si no sobrepasa la distancia
                  REGION(xn,yn) = 1;  % es un pixel similar
                  Vecinos_Pendientes = [Vecinos_Pendientes;xn,yn];
               else
                  REGION(xn,yn)=0;                                      
               end  
            end
        end
        Vecinos_Pendientes(1,:)=[];
    end
    if(exist('y','var')==0)
      close('SEGMENTACION');
    end
  close(h1)
end
