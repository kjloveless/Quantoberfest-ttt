namespace tic_tac_toe {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    
    @EntryPoint()
    operation SayHello() : Unit {
        let runs = 1;
        for i in 1..runs {                        
            mutable quantumBoard = QuantumBoard();
            mutable classicBoard = ClassicalBoard();
            use qXs = Qubit[5];
            use qOs = Qubit[5];
            PrintPlayerQubits("X", qXs);
            PrintPlayerQubits("O", qOs);
            Message("");

            set quantumBoard = PlacePiece(quantumBoard, 0, qXs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 4, qXs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 1, qOs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 4, qOs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 0, qXs[1]);
            set quantumBoard = PlacePiece(quantumBoard, 3, qXs[1]);
            set quantumBoard = PlacePiece(quantumBoard, 1, qOs[1]);
            set quantumBoard = PlacePiece(quantumBoard, 3, qOs[1]);

            let box = 1;
            let idx = CollapseSquare(quantumBoard[box]);
            let sq = quantumBoard[box][idx];
            set classicBoard w/= box <- GetToken(sq, qXs);
            PrintCollapse(box + 1, classicBoard[box], sq);
            Message("");
            PrintBoard(quantumBoard, classicBoard);
        }
    }

    function PrintPlayerQubits(t: String, qs: Qubit[]) : Unit {
        mutable msg = $"{t} Qubits [";
        for q in qs {
            set msg = $"{msg} {q} ";
        }
        set msg = $"{msg}]";
        Message(msg);
    }

    function PrintCollapse(i: Int, t: String, q: Qubit) : Unit {
        Message($"Square {i} is {t}; containing {q}.");
    }

    function IsPresentInArray(q : Qubit, array : Qubit[]) : Bool {
        let predicate = (a, b) -> a == b;
        return Count<Qubit>(predicate(q, _), array) > 0;
    }

    //Allways compare against X array
    function GetToken(q: Qubit, qs: Qubit[]) : String {
        let predicate = (a, b) -> a == b;
        let present = Count<Qubit>(predicate(q, _), qs) > 0;
        return present ? "X" | "O";
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

    operation QuantumBoard() : Qubit[][] {
        mutable result = ConstantArray<Qubit[]>(9, EmptyArray<Qubit>());
        for i in 0..8 {
            set result += EmptyArray<Qubit[]>();
        }
        return result;
    }

    function PrintBoard(qBoard : Qubit[][], cBoard : String[]) : Unit {
        Message("Quantum Board");
        mutable b = "";
        for i in 0..8 {
            set b = $"{b} | {qBoard[i]}";
            if ModI(i, 3) == 2 {
                set b = $"{b} |\n----------------\n";
            }
        }
        Message(b);

        Message("Classical Board");
        set b = "";
        for i in 0..8 {
            set b = $"{b} | {cBoard[i]}";
            if ModI(i, 3) == 2 {
                set b = $"{b} |\n----------------\n";
            }
        }
        Message(b);
    }

    function ClassicalBoard() : String[] {
        return ConstantArray<String>(9, "");
    }
}
