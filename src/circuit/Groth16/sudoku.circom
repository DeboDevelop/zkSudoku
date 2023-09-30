pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";

template Sudoku() {
    signal input unSolved[9][9];
    signal input solved[9][9];

    // Check if each cell of the solved sudoku are >=1 and <=9
    component moreThanEqOne[9][9];
    component LessThanEqNine[9][9];

    for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
            // 32 is the number of bits
            LessThanEqNine[i][j] = LessEqThan(32);
            LessThanEqNine[i][j].in[0] <== solved[i][j];
            LessThanEqNine[i][j].in[1] <== 9;

            moreThanEqOne[i][j] = GreaterEqThan(32);
            moreThanEqOne[i][j].in[0] <== solved[i][j];
            moreThanEqOne[i][j].in[1] <== 1;

            // Both LessThanEqNine[i][j], moreThanEqOne[i][j] should be 1 and thus equal
            LessThanEqNine[i][j].out === moreThanEqOne[i][j].out;
        }
    }

    // Check if unsolved is the initial state of solved
    component isSolved[9][9];
    component isEmpty[9][9];

    for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
            // If isSolved[i][j] is not 0, it means that solved[i][j] is equal to unsolved[i][j]
            // If isSolved[i][j] is 0, it means that solved [i][j] is not equal unsolved[i][j]
            isSolved[i][j] = IsEqual();
            isSolved[i][j].in[0] <== solved[i][j];
            isSolved[i][j].in[1] <== unSolved[i][j];

            // If IsZero[i][j] is not 0, it means that unsolved[i][j] is equal to 0
            // If IsZero[i][j] is 0, it means that unsolved[i][j] is not equal to 0
            isEmpty[i][j] = IsZero();
            isEmpty[i][j].in <== unSolved[i][j];

            // Therefore, if isSolved[i][j] is 1, then isEmpty[i][j] is 0. Thus, 1 === 1 - 0
            // if isSolved[i][j] is 0, then isEmpty[i][j] is 1. Thus 0 === 1 - 1
            isSolved[i][j].out === 1 - isEmpty[i][j].out;
        }
    }


    // Check if each row in solved has all the numbers from 1 to 9 (inclusive)
    // and no number is repeated.

    // 9 * 9 * 4 = 324 Checks
    component isValidRow[324];

    var indexRow = 0;

    for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
            for (var k = 0; k < j; k++) {
                isValidRow[indexRow] = IsEqual();
                isValidRow[indexRow].in[0] <== solved[i][k];
                isValidRow[indexRow].in[1] <== solved[i][j];
                isValidRow[indexRow].out === 0;
                indexRow ++;
            }
        }
    }


    // Check if each column in solved has all the numbers from 1 to 9 (inclusive)
    // and no number is repeated.

    component isValidCol[324];

    var indexCol = 0;

    for (var i = 0; i < 9; i++) {
       for (var j = 0; j < 9; j++) {
            for (var k = 0; k < i; k++) {
                isValidCol[indexCol] = IsEqual();
                isValidCol[indexCol].in[0] <== solved[k][j];
                isValidCol[indexCol].in[1] <== solved[i][j];
                isValidCol[indexCol].out === 0;
                indexCol ++;
            }
        }
    }

    // Check if each square in solved has all the numbers from 1 to 9 (inclusive)
    // and no number is repeated.

    component isValidSquare[324];

    var indexSquare = 0;

    // For each block - i and j loop
    for (var i = 0; i < 9; i+=3) {
        for (var j = 0; j < 9; j+=3) {
            // For each cell in a block, k and l loop
            for (var k = i; k < i+3; k++) {
                for (var l = j; l < j+3; l++) {
                    // For Comparing pair of cells
                    for (var m = i; m <= k; m++) {
                        for (var n = j; n < l; n++){
                            isValidSquare[indexSquare] = IsEqual();
                            isValidSquare[indexSquare].in[0] <== solved[m][n];
                            isValidSquare[indexSquare].in[1] <== solved[k][l];
                            isValidSquare[indexSquare].out === 0;
                            indexSquare ++;
                        }
                    }
                }
            }
        }
    }
}

// unSolved is a public input signal.
component main {public [unSolved]} = Sudoku();
