namespace tic_tac_toe {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    
    @EntryPoint()
    operation SayHello() : Unit {
        for i in 1..10 {
            //use qubits = Qubit[4];
            //let size1 = CollapseSquare(qubits[0..0]);
            //let size2 = CollapseSquare(qubits[0..1]);
            //let size3 = CollapseSquare(qubits[0..2]);        
            //let size4 = CollapseSquare(qubits);
            //Message($"1 Piece : {size1} \t 2 Pieces : {size2} \t 3 Pieces : {size3} \t 4 Pieces : {size4}");
                        
            mutable board = BuildBoard();
            use qXs = Qubit[5];
            use qOs = Qubit[5];
            set board = PlacePiece(board, 0, qXs[0]);
            set board = PlacePiece(board, 0, qOs[0]);
            set board = PlacePiece(board, 0, qXs[1]);
            let sq1 = CollapseSquare(board[0]);
            Message($"Square 1 : {sq1}");
        }
    }

    //Collapse the entangled Xs and Os on a square.
    //Returned is the index of the piece that gets to claim the square.
    //Only works for up to 4 entangled pieces in a square.
    operation CollapseSquare(Qubits : Qubit[]) : Int {
        let len = Length(Qubits);
        if len == 1 { return 0; }
        H(Qubits[0]);
        CNOT(Qubits[0], Qubits[1]);
        X(Qubits[1]);
        if len > 2 {
            H(Qubits[1]);
            CNOT(Qubits[0], Qubits[2]);
            CNOT(Qubits[1], Qubits[2]);
            X(Qubits[2]);
        }
        let outcome = MeasureEachZ(Qubits);

        ResetAll(Qubits);

        for i in 0..(len-1) {
            if len == 2 { 
                if outcome[i] == One {
                    return i;
                }
			} elif outcome[i] == Zero {

            } else {
                if outcome[0] == One and outcome[1] == One {
                    if len == 3 {
                        return CollapseSquare(Qubits);
                    }
                    return 3;
                } else {
                    return i;
                }
            }
        }
                
        return -1;
    }

    operation PlacePiece(Board: Qubit[][], Square: Int, Piece: Qubit) : Qubit[][] {
        let Len = Length(Board[Square]);
        mutable board = Board;
        mutable square = Board[Square];

        if Len == 0 {
            set square = [Piece];
        } else
        {
            set square += [Piece];
        }

        set board w/= Square <- square; 
        return board;
    }

    operation BuildBoard () : Qubit[][] {
        mutable result = ConstantArray<Qubit[]>(9, EmptyArray<Qubit>());
        for i in 0..8 {
            set result += EmptyArray<Qubit[]>();
        }
        return result;
    }
}
