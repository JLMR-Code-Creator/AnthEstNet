classdef Head
    methods(Static)
         function  Library()
            addpath src
            addpath src/ICC % Load code files
            addpath src/RGB2PCS
            addpath src/Segmentation
            addpath src/Images       %For the set of images
            addpath src/anthocyanin
            addpath src/DBCode
            addpath src/Color_characterization
            close all;
            clear;
            clc;
         end 
    end
end

