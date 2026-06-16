%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demanda Agregada, Mercado de Fondos Prestables, Inflación: IS-FP-PC (Keynes-Garrison-Phillips)
% Versión Dinámica de Mediano Plazo 
% Autor: Diego
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

%% 1. PARÁMETROS MACROECONÓMICOS
T       = 60;       % Número de períodos de simulación

% Demanda Agregada (Keynes)
C0      = 180;      % Consumo autónomo
c       = 0.65;     % Propensión marginal a consumir
t       = 0.15;     % Tasa impositiva (Ingreso disponible = (1-t)*Y)
G0      = 220;      % Gasto público autónomo
NX0     = 50;       % Exportaciones netas autónomas
m       = 0.10;     % Propensión marginal a importar

% Mercado de Fondos Prestables e Inversión (Garrison)
A       = 250;      % Demanda autónoma de fondos prestables (Deseo de inversión)
alpha   = 300;      % Sensibilidad de los fondos prestables a la tasa de interés
I0      = 150;      % Inversión autónoma estructural
tau     = 250;      % Sensibilidad de la inversión a la tasa de interés
s       = 0.25;     % Propensión marginal al ahorro (sobre el ingreso disponible)

% Oferta, Capacidad y Frontera Productiva (Hayek / Crecimiento)
Y_cap0  = 1000;     % Capacidad productiva inicial (Frontera inicial)
delta   = 0.05;     % Eficiencia de la inversión (Conversión de I_t en nueva capacidad)
betaPC  = 0.02;     % Sensibilidad de la inflación al output gap

%% 2. INICIALIZACIÓN DE VARIABLES
Y       = zeros(T,1);   % Producto Real Efectivo
Y_dem   = zeros(T,1);   % Producto de Demanda (Keynesiano)
Y_cap   = zeros(T,1);   % Capacidad Productiva Máxima (Frontera FPP)
C       = zeros(T,1);   % Consumo Privado
I       = zeros(T,1);   % Inversión Privada
r       = zeros(T,1);   % Tasa de Interés Real de Equilibrio
pi      = zeros(T,1);   % Tasa de Inflación
P       = zeros(T,1);   % Nivel General de Precios

% Condiciones Iniciales
Y(1)      = 950;        % Iniciamos en una brecha recesiva inicial
Y_cap(1)  = Y_cap0;     % Capacidad instalada inicial
pi(1)     = 0.02;       % Inflación inicial del 2%
P(1)      = 100;        % Índice de precios base
r(1)      = 0.04;       % Tasa de interés inicial (4%)

%% 3. BUCLE DE SIMULACIÓN DINÁMICA
for k = 2:T
    
    % A) Mercado de Fondos Prestables con Ahorro sobre Ingreso Disponible
    % r equilibra la oferta de fondos (S) y el deseo autónomo de invertir (A)
    r(k) = (A - s * (1 - t) * Y(k-1)) / alpha;
    r(k) = max(r(k), 0.005); % Límite inferior técnico (Piso del 0.5%)
    
    % B) Estructura de Capital e Inversión (Triángulo de Hayek)
    I(k) = I0 - tau * r(k);
    
    % C) Evolución Endógena de la Capacidad Productiva (Frontera de Producción)
    % La inversión física desplaza la FPP hacia la derecha en el período t+1
    Y_cap(k) = Y_cap(k-1) + delta * I(k-1);
    
    % D) Determinación de la Demanda Agregada Keynesiana
    C(k) = C0 + c * (1 - t) * Y(k-1);
    NX   = NX0 - m * Y(k-1);
    Y_dem(k) = C(k) + I(k) + G0 + NX;
    
    % E) Restricción de Frontera de Producción (FPP)
    % La economía no puede producir más allá de su capacidad real instalada
    Y(k) = min(Y_dem(k), Y_cap(k));
    
    % F) Dinámica Inflacionaria (Curva de Phillips)
    % Las presiones surgen si la demanda presiona la capacidad instalada
    output_gap = (Y(k) - Y_cap(k)) / Y_cap(k);
    pi(k) = pi(k-1) + betaPC * output_gap;
    
    % G) Nivel de Precios
    P(k) = P(k-1) * (1 + pi(k));
end

% Ajuste estético para el período inicial
I(1) = I0 - tau * r(1);
C(1) = C0 + c * (1 - t) * Y(1);
Y_dem(1) = Y(1);

%% 4. VISUALIZACIÓN DE RESULTADOS
figure('Name', 'Simulación IS-FP-PC con Frontera Endógena', 'Position', [100, 100, 1000, 600]);

% Gráfico 1: PIB de Demanda vs Capacidad de Oferta e Impacto del Min()
subplot(2,2,1);
plot(Y, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
hold on;
plot(Y_cap, '--r', 'LineWidth', 1.5);
title('Gross Domestic Product & Production Frontier');
xlabel('Periods'); ylabel('USD');
legend('Effective GDP', 'Production Capacity (FPP)', 'Location', 'Best');
grid on;

% Gráfico 2: Tasa de Interés Real Endógena
subplot(2,2,2);
plot(r * 100, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]);
title('Real Interest Rate (Loanable Funds Equilibrium)');
xlabel('Periods'); ylabel('Percentage (%)');
grid on;

% Gráfico 3: Inflación Amortiguada
subplot(2,2,3);
plot(pi * 100, 'LineWidth', 2, 'Color', [0.9290 0.6940 0.1250]);
title('Inflation Rate Dynamics (Phillips Curve)');
xlabel('Periods'); ylabel('Annual %');
grid on;

% Gráfico 4: Inversión que Alimenta el Capital Estructural
subplot(2,2,4);
plot(I, 'LineWidth', 2, 'Color', [0.4660 0.6740 0.1880]);
title('Private Investment (Capital Accumulation)');
xlabel('Periods'); ylabel('USD');
grid on;
