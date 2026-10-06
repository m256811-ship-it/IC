classdef autoencoderVLC4paredesTest < matlab.unittest.TestCase

    methods (Test)

        function testLOSIndependentOfPatchResolution(testCase)

            %% Parametros base
            params = getBaseParams();

            %% Somente LOS
            params.includeLOS = true;
            params.includeNLOS = false;
            params.normalize = "none";

            %% Posicoes fixas
            lz = params.room(3);

            TP1 = [0 0 lz/2];
            RP  = [0 0 -lz/2];

            %% Resolucao espacial
            ppmVec = [2 5 10 20 40];

            channels = cell(size(ppmVec));

            for i = 1:length(ppmVec)

                params.patchesPerMeter = ppmVec(i);

                [h, ~] = ...
                    generateVLCChannelH_ChannelModelingSlides( ...
                        params, TP1, RP);

                channels{i} = h;

            end

            %% Verificacao

            % Como NLOS esta desligado, patchesPerMeter nao deve
            % alterar o canal LOS.

            for i = 2:length(channels)

                verifyEqual( ...
                    testCase, ...
                    channels{i}, ...
                    channels{1}, ...
                    "AbsTol", 1e-12);

            end

        end


        function testNLOSConvergence(testCase)

            %% Parametros base
            params = getBaseParams();

            %% Somente NLOS
            params.includeLOS = false;
            params.includeNLOS = true;

            % Importante:
            % nao normalizar para observar a convergencia fisica do ganho
            params.normalize = "none";

            %% Posicoes fixas

            lz = params.room(3);

            TP1 = [0 0 lz/2];
            RP  = [0 0 -lz/2];

            %% Resolucao espacial

            ppmVec = [2 5 10 20 40];

            channelGain = zeros(size(ppmVec));
            peakGain = zeros(size(ppmVec));
            rmsDelaySpread = zeros(size(ppmVec));

            channels = cell(size(ppmVec));
            times = cell(size(ppmVec));

            %% Gera canal para cada resolucao

            for i = 1:length(ppmVec)

                params.patchesPerMeter = ppmVec(i);

                [h, t_ns] = ...
                    generateVLCChannelH_ChannelModelingSlides( ...
                        params, TP1, RP);

                channels{i} = h;
                times{i} = t_ns;

                %% Ganho total do canal

                channelGain(i) = sum(h);

                %% Pico do canal

                peakGain(i) = max(h);

                %% RMS delay spread

                if sum(h) > 0

                    tauMean = ...
                        sum(t_ns .* h) / sum(h);

                    rmsDelaySpread(i) = sqrt( ...
                        sum(((t_ns - tauMean).^2) .* h) ...
                        / sum(h));

                else

                    rmsDelaySpread(i) = 0;

                end

            end

            %% Variacoes relativas entre resolucoes consecutivas

            gainRelativeChange = [NaN, ...
                abs(diff(channelGain)) ./ ...
                max(abs(channelGain(1:end-1)), eps)];

            delayRelativeChange = [NaN, ...
                abs(diff(rmsDelaySpread)) ./ ...
                max(abs(rmsDelaySpread(1:end-1)), eps)];

            %% Exibir resultados

            resultsTable = table( ...
                ppmVec(:), ...
                channelGain(:), ...
                peakGain(:), ...
                rmsDelaySpread(:), ...
                gainRelativeChange(:), ...
                delayRelativeChange(:), ...
                'VariableNames', { ...
                'PatchesPerMeter', ...
                'ChannelGain', ...
                'PeakGain', ...
                'RMSDelaySpread_ns', ...
                'GainRelativeChange', ...
                'DelayRelativeChange' ...
                });

            disp(' ');
            disp('==============================================');
            disp('Teste de convergencia espacial do canal NLOS');
            disp('==============================================');
            disp(resultsTable);

            %% Criterio de convergencia

            tolerance = 0.01;   % 1%

            % Compara as duas maiores resolucoes:
            % 20 patches/m -> 40 patches/m

            verifyLessThan( ...
                testCase, ...
                gainRelativeChange(end), ...
                tolerance);

            verifyLessThan( ...
                testCase, ...
                delayRelativeChange(end), ...
                tolerance);

        end


        function testFullChannelConvergence(testCase)

            %% Parametros base

            params = getBaseParams();

            %% LOS + NLOS

            params.includeLOS = true;
            params.includeNLOS = true;
            params.normalize = "none";

            %% Posicoes fixas

            lz = params.room(3);

            TP1 = [0 0 lz/2];
            RP  = [0 0 -lz/2];

            %% Resolucao

            ppmVec = [2 5 10 20 40];

            channelGain = zeros(size(ppmVec));

            for i = 1:length(ppmVec)

                params.patchesPerMeter = ppmVec(i);

                [h, ~] = ...
                    generateVLCChannelH_ChannelModelingSlides( ...
                        params, TP1, RP);

                channelGain(i) = sum(h);

            end

            %% Variacao relativa

            relativeChange = ...
                abs(channelGain(end) - channelGain(end-1)) ...
                / max(abs(channelGain(end-1)), eps);

            fprintf('\n');
            fprintf('Convergencia do canal completo:\n');
            fprintf('20 patches/m: %.12e\n', channelGain(end-1));
            fprintf('40 patches/m: %.12e\n', channelGain(end));
            fprintf('Variacao relativa: %.6f %%\n', ...
                relativeChange*100);

            %% Critério

            verifyLessThan( ...
                testCase, ...
                relativeChange, ...
                0.01);

        end

    end

end


