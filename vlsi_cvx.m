% Timing Optimization in VLSI circuits using Sequential Convex Programming (SCP)
% This example focuses on minimizing the delay on critical paths.

% Clear previous variables
clear;
clc;

% Parameters
num_paths = 5; % Number of timing paths
num_stages = 3; % Number of stages/buffers per path
max_iterations = 10; % Maximum number of SCP iterations
tolerance = 1e-3; % Convergence tolerance for SCP

% Initial delay matrix (randomly initialized for illustration)
% Rows: Paths, Columns: Stages
delays = rand(num_paths, num_stages);

% Initial buffer sizing (normalized, can be adjusted in SCP)
buffer_sizing = ones(1, num_stages);

% Target delay for optimization (based on initial delays)
target_delay = max(sum(delays, 2)) * 0.9;

% SCP Loop
for iter = 1:max_iterations
    fprintf('Iteration %d\n', iter);
    
    % Linearize the delay model around the current buffer sizing
    approx_delays = delays .* repmat(buffer_sizing, num_paths, 1);
    
    % Solve the convex optimization problem using CVX
    cvx_begin quiet
        variables new_buffer_sizing(1, num_stages) new_delays(num_paths)
        % Objective: Minimize the maximum delay across all paths
        minimize(max(new_delays))
        
        % Constraints: Linearized delay model
        for i = 1:num_paths
            new_delays(i) == sum(approx_delays(i, :) .* (new_buffer_sizing ./ buffer_sizing));
        end
        
        % Ensure non-negative buffer sizes
        new_buffer_sizing >= 0;
        
        % Ensure delays are below target delay
        new_delays <= target_delay;
    cvx_end
    
    % Convergence check
    if norm(new_buffer_sizing - buffer_sizing) < tolerance
        disp('Converged!');
        break;
    end
    
    % Update buffer sizing for the next iteration
    buffer_sizing = new_buffer_sizing;
    
    % Display current maximum delay
    fprintf('Max Delay: %.4f\n', max(new_delays));
end

% Display final results
disp('Final Buffer Sizing:');
disp(buffer_sizing);

disp('Final Path Delays:');
disp(new_delays);

disp(['Final Max Delay: ', num2str(max(new_delays))]);

% Plot the path delays for visualization
figure;
bar(new_delays);
title('Final Optimized Path Delays');
xlabel('Path Index');
ylabel('Delay');
grid on;
