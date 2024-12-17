function TicTacToe()
    clc;
    clear;
    clear all;
    close force all;


    % Create and train the neural network
    net = createAndTrainNetworkO();
    net2 = createAndTrainNetworkX();

    [hFigure, hAxes, gameBoard, squareEdgeSize] = initializeGame();
    
    currentPlayer = -1; % Start with player 1
    playersdict = dictionary([-1, 0, 1],["X", "_", "O"]); % 0: empty, -1: player 1 (X), 1: player 2 (O)

    is_game_run = true;
    while is_game_run
        if currentPlayer == -1
            % Player 1's turn (human)
            waitforbuttonpress;
            % [row, col] = getAIMove(net2, gameBoard);
            % OnPatchPressedCallback([], [], row, col);
        else
            % Player 2's turn (AI)
            % waitforbuttonpress;
            [row, col] = getAIMove(net, gameBoard);
            OnPatchPressedCallback([], [], row, col);
        end
    end




    function [hFigure, hAxes, gameBoard, squareEdgeSize] = initializeGame()
    
        % Create figure and axes
        hFigure = figure('Name', 'Tic Tac Toe', 'NumberTitle', 'off', ...
                         'Position', [100, 100, 300, 300], 'MenuBar', 'none', ...
                         'SizeChangedFcn', @resizeCallback);
        hAxes = axes('Parent', hFigure);
        axis equal;
        axis off;
        hold on;
    
        % Define grid properties
        squareEdgeSize = 1;
        hPatchObjects = zeros(3, 3);
        gameBoard = 0 * ones(3, 3);
    
        % Create the grid
        for row = 1:3
            for col = 1:3
                hPatchObjects(row, col) = rectangle('Position', ...
                    [(col - 1) * squareEdgeSize, (row - 1) * squareEdgeSize, ...
                    squareEdgeSize, squareEdgeSize], ...
                    'FaceColor', [0.7, 0.9, 0.9], ...
                    'EdgeColor', 'k', 'LineWidth', 2, ...
                    'HitTest', 'on', ...
                    'ButtonDownFcn', {@OnPatchPressedCallback, row, col});
            end
        end
    
        set(hAxes, 'YDir', 'reverse');
    end





    
    function OnPatchPressedCallback(hObject, ~, rowIndex, colIndex)
        % Check if the cell is already occupied
        if gameBoard(rowIndex, colIndex) == 0
            % Determine the symbol and color based on the current player
            if currentPlayer == -1
                symbol = 'X';
                color = 'r'; % Red for X
            else
                symbol = 'O';
                color = 'b'; % Blue for O
            end
            
            % Get current font size based on figure size
            figPos = get(hFigure, 'Position');
            fontSize = min(figPos(3), figPos(4)) / 6;

            % Place the outline (black) slightly offset
            text((colIndex - 0.5) * squareEdgeSize, (rowIndex - 0.5) * squareEdgeSize, ...
                symbol, 'FontSize', fontSize + 4, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', 'k', 'FontWeight', 'bold');

            % Place the symbol in the center of the square
            text((colIndex - 0.5) * squareEdgeSize, (rowIndex - 0.5) * squareEdgeSize, ...
                symbol, 'FontSize', fontSize, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', color, 'FontWeight', 'bold');

            % Update game board
            % clc;
            gameBoard(rowIndex, colIndex) = currentPlayer;
            disp(gameBoard);
            
            if checkWin(currentPlayer, gameBoard)
                is_game_run = false;
                winnerMessage = sprintf('Игрок %s выиграл!', playersdict(currentPlayer));
                disp(winnerMessage);
                msgbox(winnerMessage); % Display winner message in a message box
                return;
            end
             % Check for a draw (if all cells are filled and no winner)
            if all(gameBoard(:) ~= 0)
                is_game_run = false; % End the game
                winnerMessage = 'Игра закончилась вничью!'; % Draw message
                disp(winnerMessage);
                msgbox(winnerMessage); % Display draw message in a message box
                return;
            end
            % Switch players
            currentPlayer = -currentPlayer; % Toggle between -1 and 1
            pause(1);%0.2
            fprintf("Ход игрока %s\n", playersdict(currentPlayer));
        end
    end





    function resizeCallback(~, ~)
        % This function is called whenever the figure is resized.
        % Clear previous text objects before resizing.
        if exist('hAxes', 'var') % Prevent undefined error on start
            delete(findall(hAxes, 'Type', 'text'));
        
            % Redraw all symbols based on current game state.
            for row = 1:3
                for col = 1:3
                    if gameBoard(row,col) ~= 0
                        if gameBoard(row,col) == -1
                            symbol = 'X';
                            color = 'r'; % Red for X
                        else
                            symbol = 'O';
                            color = 'b'; % Blue for O
                        end
                        
                        figPos = get(hFigure, 'Position');
                        fontSize = min(figPos(3), figPos(4)) / 6;
    
                        % Place the outline (black) slightly offset
                        text((col - 0.5) * squareEdgeSize, (row - 0.5) * squareEdgeSize, ...
                            symbol, 'FontSize', fontSize + 4, ...
                            'HorizontalAlignment', 'center', ...
                            'VerticalAlignment', 'middle', ...
                            'Color', 'k', ...
                            'FontWeight', 'bold');
    
                        % Place the symbol in the center of the square
                        text((col - 0.5) * squareEdgeSize, (row - 0.5) * squareEdgeSize, ...
                            symbol, ...
                            'FontSize', fontSize, ...
                            'HorizontalAlignment', 'center', ...
                            'VerticalAlignment', 'middle', ...
                            'Color', color, ...
                            'FontWeight', 'bold');
                    end
                end
            end 

        end
    end




    function win = checkWin(player, gameBoard)
        win = false;
        % Check rows and columns for wins
        for i = 1:3
            if all(gameBoard(i,:) == player) || all(gameBoard(:,i) == player)
                win = true;
                is_game_run = false;
                return;
            end
        end
        % Check diagonals for wins
        if all(diag(gameBoard) == player) || all(diag(flipud(gameBoard)) == player)
            win = true;
            is_game_run = false;
            return;
        end
    end




%%%%%%%%%%%%%%%%%%%%%%%%%%AI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function net = createAndTrainNetworkO()
        wanttoload = 1;
        if wanttoload == 0
            % Generate training data (inputs and targets)
            [P, T] = generateTrainingData(1);

            % disp('Training Data P and T pairs:');
            % for i = 1:size(P, 1)
            %     % disp(['Size of P: ', num2str(size(P, 1)), ' rows']);
            %     % disp(['Size of T: ', num2str(size(T, 1)), ' rows']);
            %     fprintf('P(%d): %s\nT(%d): %s\n\n', i, mat2str(P(i, :)), i, mat2str(T(i, :)));
            % end

            % Create the neural network
            net = newff(minmax(P'),[9,27,9], {'tansig' 'tansig' 'softmax'}, 'trainlm');

            net.trainParam.epochs = 300;
            net.trainParam.goal = 0.0001;
            net.performFcn = 'mse';

            size(P)
            size(T)

            net = train(net, P', T');

            TicTacNetO = net
            save TicTacNetO
        else
            loadedData = load('TicTacNetO.mat');
            net = loadedData.net;
        end

    end

    function net2 = createAndTrainNetworkX()
        wanttoload = 1;
        if wanttoload == 0
            [P2, T2] = generateTrainingData(-1);
            net2 = newff(minmax(P2'),[9,27,9], {'tansig' 'tansig' 'softmax'}, 'trainlm');
            net2.trainParam.epochs = 300;
            net2.trainParam.goal = 0.0001;
            net2.performFcn = 'mse';
            net2 = train(net, P2', T2');

            TicTacNetX = net2
            save TicTacNetX
        else
            loadedData = load('TicTacNetX.mat');
            net2 = loadedData.net2;
        end
    end









    function [P, T] = generateTrainingData(whototeach)
        
        P = []; % Input matrix
        T = []; % Target matrix
    
        % Simulate a number of games
        for first_player = [-1]
            numWins1 = 0;
            numWins2 = 0;
            while numWins1 ~= 500 && numWins2 ~= 500
                gameBoard = 0 * ones(3, 3); % Start with an empty board
                currentPlayer = first_player; % Start with player 1 (X)
                fprintf("%d      %d   %d\n", first_player,numWins1,numWins2);
                while true
                    % Get all possible moves
                    emptyCells = find(gameBoard(:) == 0);
                    if isempty(emptyCells)
                        break; % No more moves
                    end
    
                    % Randomly select a move for the current player
                    if currentPlayer == -whototeach%%%
                        moveIndex = emptyCells(randi(length(emptyCells)));
                        % moveIndex = smartMove(gameBoard, currentPlayer);
                        row = mod(moveIndex - 1, 3) + 1;
                        col = ceil(moveIndex / 3);
                        % Update the game board
                        gameBoard(row, col) = currentPlayer;
                    else
                        moveIndex = smartMove(gameBoard, currentPlayer);
                        row = mod(moveIndex - 1, 3) + 1;
                        col = ceil(moveIndex / 3);
                    end
                        
                    if currentPlayer == whototeach %Circle
                        % Record the input
                        P = [P; gameBoard(:)']; % Flatten the game board for input
                    end
                    
                    % Update the game board
                    gameBoard(row, col) = currentPlayer;
                    
                    if currentPlayer == whototeach %Circle
                        % Record the target
                        target = zeros(1, 9);
                        target(moveIndex) = 1; % One-hot encoding for the move
                        T = [T; target]; % Append the target
                    end
                    
                        % gameBoard
                    % Check for a win or draw
                    if checkWin(-1, gameBoard)
                        numWins1 = numWins1 + 1;
                        break; % End the game if there's a winner
                    end
                    if checkWin(1, gameBoard)
                        numWins2 = numWins2 + 1;
                        break; % End the game if there's a winner
                    end
        
                    % Switch players
                    currentPlayer = -currentPlayer; % Toggle between -1 and 1
                    % clc;
                end
            end
        end
    end
    
    
    
    function moveIndex = smartMove(gameBoard, player)
        % Check for winning move
        moveIndex = findWinningMove(gameBoard, player);
        if ~isempty(moveIndex)
            return; % Return winning move if found
        end

        % Check for blocking move
        opponent = -player; % Get the opponent's player number
        moveIndex = findWinningMove(gameBoard, opponent);
        if ~isempty(moveIndex)
            return; % Block opponent's winning move if found
        end
        
        % If no winning or blocking moves, choose a random available move
        emptyCells = find(gameBoard(:) == 0);
        moveIndex = selectMoveWithPriority(gameBoard, emptyCells, player); % Use priority-based selection
    end
    
    function winningMove = findWinningMove(gameBoard, player)
        % Check all possible moves to see if there's a winning move
        for i = 1:9
            if gameBoard(i) == 0 % If cell is empty
                tempBoard = gameBoard; % Make a copy of the board
                tempBoard(i) = player; % Simulate the player's move
                
                if checkWin(player, tempBoard) % Check if this is a winning move
                    winningMove = i; % Return the index of the winning move
                    return;
                end
            end
        end
        winningMove = []; % No winning move found
    end
    
    function moveIndex = selectMoveWithPriority(gameBoard, emptyCells, player)
        % Define the priority order: center > corners > edges
        priorityOrder = [5, 1, 3, 7, 9, 2, 4, 6, 8]; % 1-based indices
    
        opponent = -player;
        

        corners = [1, 3, 7, 9]; % 1-based indices for corners
        oppositeCorners = [9, 7, 3, 1]; % Opposite corners corresponding to the above
        notcorners = [2,4,6,8];


        % pattern1 = [0, 0, -1, 0, 1, 0, 0, -1, 0];
        % pattern1right = [0, 0, -1, 0, 1, 0, 0, -1, 1];
        % 
        % pattern2 = [0, 0, 0, 0, 1, -1, 0, -1, 0];
        % pattern2right = [0, 0, 0, 0, 1, -1, 0, -1, 1];

        pattern1 = [0, 0, opponent, 0, player, 0, 0, opponent, 0];
        pattern1right = [0, 0, opponent, 0, player, 0, 0, opponent, player];

        pattern2 = [0, 0, 0, 0, player, opponent, 0, opponent, 0];
        pattern2right = [0, 0, 0, 0, player, opponent, 0, opponent, player];

        
        moveIndex = checkSpecificPattern(pattern1, pattern1right, gameBoard);
        if ~isempty(moveIndex)
            return;
        end

        moveIndex = checkSpecificPattern(pattern2, pattern2right, gameBoard);
        if ~isempty(moveIndex)
            return;
        end




        % Check for opponent's corner moves and take the opposite if available
        for i = 1:length(corners)
            if gameBoard(corners(i)) == opponent 
                if gameBoard(oppositeCorners(i)) == opponent  % Check if the opposite corner is available
                    emptyNotCorners = intersect(notcorners, emptyCells);
                    moveIndex = emptyNotCorners(randi(length(emptyNotCorners)));
                    return; % Return the move
                end
            end
        end

        
        % Check for available moves in priority order
        for i = 1:length(priorityOrder)
            if ismember(priorityOrder(i), emptyCells)
                moveIndex = priorityOrder(i);
                return; % Return the first available move in priority order
            end
        end
        
        % If no priority moves are available, select randomly from empty cells
        moveIndex = emptyCells(randi(length(emptyCells))); % Randomly select an empty cell
    end

    function isMatch = matchesPattern(gameBoard, pattern)
        isMatch = true; % Assume it matches unless proven otherwise
        for i = 1:9
            if pattern(i) ~= 0 % Only check non-zero values in the pattern
                if gameBoard(i) ~= pattern(i)
                    isMatch = false; % Mismatch found
                    return;
                end
            end
        end
    end

    function moveIndex = checkSpecificPattern(pattern1, pattern1right, gameBoard)
        moveIndex = [];
        % Reshape patterns to 3x3 matrices
        pattern1_3x3 = reshape(pattern1, [3, 3]);
        pattern1right_3x3 = reshape(pattern1right, [3, 3]);
    
        % Check patterns with rotation and all flips
        for i = 1:3
            % Check original patterns
            if matchesPattern(gameBoard, pattern1_3x3) && ~matchesPattern(gameBoard, pattern1right_3x3)
                moveIndex = find(pattern1_3x3 ~= pattern1right_3x3);
                return;
            end
    
            % Check mirrored pattern1 (horizontal flip)
            mirrored1_h = flip(pattern1_3x3, 2); % Horizontal flip
            mirrored1right_h = flip(pattern1right_3x3, 2);
            if matchesPattern(gameBoard, mirrored1_h) && ~matchesPattern(gameBoard, mirrored1right_h)
                moveIndex = find(mirrored1_h ~= mirrored1right_h);
                return;
            end
    
            % Check mirrored pattern1 (vertical flip)
            mirrored1_v = flip(pattern1_3x3, 1); % Vertical flip
            mirrored1right_v = flip(pattern1right_3x3, 1);
            if matchesPattern(gameBoard, mirrored1_v) && ~matchesPattern(gameBoard, mirrored1right_v)
                moveIndex = find(mirrored1_v ~= mirrored1right_v);
                return;
            end
    
            % Check mirrored pattern1 (horizontal and vertical flip)
            mirrored1_hv = flip(flip(pattern1_3x3, 1), 2); % Combined flip
            mirrored1right_hv = flip(flip(pattern1right_3x3, 1), 2);
            if matchesPattern(gameBoard, mirrored1_hv) && ~matchesPattern(gameBoard, mirrored1right_hv)
                moveIndex = find(mirrored1_hv ~= mirrored1right_hv);
                return;
            end
    
            % Rotate patterns 90 degrees clockwise
            pattern1_3x3 = rot90(pattern1_3x3, -1);
            pattern1right_3x3 = rot90(pattern1right_3x3, -1);
        end
    end













    function [row, col] = getAIMove(net, gameBoard)
        emptyCells = find(gameBoard(:) == 0); % Find indices of empty cells  
        input = gameBoard(:); % Flatten the game board for input to the network
        AIboard = sim(net, input); % Get the scores from the neural network
    
        % Create a score vector for only the empty cells
        scoresForEmptyCells = AIboard(emptyCells);
        
        % Sort the scores in descending order and get the indices
        [sortedScores, sortedIndices] = sort(scoresForEmptyCells, 'descend');
        
        % Check for the first available move (which will be the highest score)
        if ~isempty(sortedIndices)
            bestMoveIndex = sortedIndices(1); % Get the index of the best move in the sorted list
            MoveIndex = emptyCells(bestMoveIndex); % Get the actual index in the game board
    
            % Convert the best move index back to row and column
            col = ceil(MoveIndex / 3);
            row = mod(MoveIndex - 1, 3) + 1;
            
            disp('Scores for all cells:');
            for i = 1:length(input)
                fprintf('Cell %d (Col %d, Row %d): Score = %.3f\n', ...
                        i, ...
                        ceil(i / 3), ...
                        mod(i - 1, 3) + 1, ...
                        AIboard(i));
            end
            disp(['Best move: Cell ' num2str(MoveIndex) ' (Col ' num2str(col) ', Row ' num2str(row) ')']);
        else
            error('No available moves!'); % Handle case where there are no empty cells
        end
    end





    function [row, col] = getMoveRandom(gameBoard)
        emptyCells = find(gameBoard(:) == 0); % Find indices of empty cells  

        if isempty(emptyCells)
            error('No available moves!'); 
        end
        
        randomIndex = emptyCells(randi(length(emptyCells))); % Randomly select an index from empty cells
        
        col = ceil(randomIndex / 3);
        row = mod(randomIndex - 1, 3) + 1;
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%AI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end
