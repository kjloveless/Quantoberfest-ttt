namespace tic_tac_toe {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    @EntryPoint()
    operation Start() : Unit {
        let runs = 10;
        for i in 1..runs {                        
            mutable quantumBoard = QuantumBoard();
            mutable classicBoard = ClassicalBoard();
            use qXs = Qubit[5];
            use qOs = Qubit[5];
            //PrintPlayerQubits("X", qXs);
            //PrintPlayerQubits("O", qOs);
            //Message("");

            set quantumBoard = PlacePiece(quantumBoard, 0, qXs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 4, qXs[0]);
            mutable (circ, cycle) = DetectCycle(0, qXs[1], qXs[1], quantumBoard);    
            //if circ { Message($"Cycle {circ} on Square 1 : {cycle}"); }

            set quantumBoard = PlacePiece(quantumBoard, 1, qOs[0]);
            set quantumBoard = PlacePiece(quantumBoard, 4, qOs[0]);

            set quantumBoard = PlacePiece(quantumBoard, 0, qXs[1]);
            set quantumBoard = PlacePiece(quantumBoard, 3, qXs[1]);
            set (circ, cycle) = DetectCycle(0, qXs[1], qXs[1], quantumBoard);        
            //if circ { Message($"Cycle {circ} on Square 0 : {cycle}"); }
            //set (_, cycle) = DetectCycle(3, qOs[1], qOs[1], quantumBoard);        
            //Message($"Cycle on Square {3} is {cycle}");

            set quantumBoard = PlacePiece(quantumBoard, 1, qOs[1]);
            set quantumBoard = PlacePiece(quantumBoard, 3, qOs[1]);
            //set (circ, cycle) = DetectCycle(1, qOs[1], qOs[1], quantumBoard);        
            //if circ { Message($"Cycle {circ} on Square 1 : {cycle}"); }
            set (circ, cycle) = DetectCycle(3, qOs[1], qOs[1], quantumBoard);        
            //if (circ) { Message($"Cycle {circ} on Square 3 : {cycle}"); }
            
            PrintBoard(quantumBoard, classicBoard);
                        
            mutable qBoard = quantumBoard;

            repeat  {          
                mutable idx = 1;
                mutable n = -1;
                mutable count = 0;
                mutable same = false;

                for box in cycle {   
                    let c = Exclude(RangeAsIntArray(0..n), cycle);
                    set n += 1;
                    set (idx, qBoard) = CollapseSquare(box, c, qBoard);
                    if not (idx == -1) {
                        let sq = Head(qBoard[box]);
                        set classicBoard w/= box <- GetToken(sq, qXs);
                        PrintCollapse(box + 1, classicBoard[box], sq);
                        set count += 1;
                    }
                }    

                set n = 0;
                for box in cycle {
                    let c = Exclude(RangeAsIntArray(0..n), cycle);
                    set n += 1;
                    let board = Subarray(c, qBoard);
                    mutable smallBoard = EmptyArray<Qubit>();
                    for b in board {
                        set smallBoard = smallBoard + b;
                    }
                    set same = same or IsPresentInArray(qBoard[box][0], smallBoard);
                }
            } until count == Length(cycle) and not same
            fixup {
                set qBoard = quantumBoard;                 
            }

            Message("");
            PrintBoard(qBoard, classicBoard);
            Message("\n\n");
        }
    }

    function QubitLocations(Q : Qubit, Board : Qubit[][]) : (Int, Int) {
        mutable x = -1;

        for i in 0..(Length(Board)-1) {
            let exists = IsPresentInArray(Q, Board[i]);
            if exists {
                if x == -1 { set x = i; }
                else { return (x,i); }
            }
        }

        return (x, -1);
    }

    function DetectCycle(Box : Int, Q : Qubit, OrigQ : Qubit, Board : Qubit[][]) : (Bool, Int[]) {
        let square = Board[Box];
        let len = Length(square);
        mutable result = [Box];
        mutable circ = false;
        mutable res = result;
        
        for i in (len-1)..-1..0 {
            if not (square[i] == Q) {
                if not (square[i] == OrigQ) { 
                    let (x,y) = QubitLocations(square[i], Board);
                    if x == Box { 
                        set (circ, res) = DetectCycle(y, square[i], OrigQ, Board); 
                        set result += res;
                    } else 
                    { 
                        set (circ, res) = DetectCycle(x, square[i], OrigQ, Board); 
                        set result += res;
                    }  
                } else 
                { 
                    set circ = true;
                }
            }
        }
        
        return (circ, result);
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
        Message($"Square {i} is {t} containing {q}.");
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
    operation CollapseSquare(Square : Int, Cycle : Int[], Board : Qubit[][]) : (Int, Qubit[][]) {
        let Qubits = Board[Square];
        let len = Length(Qubits);
        if len == 0 {return (-1, Board); }
        if len == 1 { return (0, Board); }
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
        mutable result = -1;

        for i in 0..(len-1) {
            if len == 2 { 
                if outcome[i] == One {
                    set result = i;
                }
			} elif outcome[i] == Zero {

            } else {
                if outcome[0] == One and outcome[1] == One {
                    if len == 3 {
                        return CollapseSquare(Square, Cycle, Board);
                    }
                    set result = 3;
                } else {
                    set result = i;
                }
            }
        }
                
        if result == -1 { return (result, Board); }

        let idx = result;
        mutable board = Board;
        mutable cycle = Cycle;
        mutable Q = Qubits[idx]; 
        mutable needsPlaced = [Qubits[AbsI(idx-1)]];
        mutable wasPlaced = [Q];

        for r in Cycle {
            set cycle = Rest(cycle);
            if not (Length(Board[r]) == 0) {
                mutable square = Board[r];
                if r == Square { 
                    set square = [Qubits[idx]];
                } elif Length(square) > 1
                {
                    if not IsEmpty(cycle) {
                        mutable done = false;
                        for s in square {
                            if not done {
                                let was = IsPresentInArray(s, wasPlaced);
                                if not was {
                                    let needs = IsPresentInArray(s, needsPlaced);
                                    if needs {
                                        set square = [s];
                                        set wasPlaced += square;
                                        let i = IndexOf((a) -> (s == a), needsPlaced);
                                        set needsPlaced = Swapped(0, i, needsPlaced);
                                        set needsPlaced = Subarray(RangeAsIntArray(1..(Length(needsPlaced)-1)), needsPlaced);
                                    } else
                                    {
                                        set needsPlaced += [s];
                                    }
                                } else 
                                { 
                                    let predicate = (a) -> not (a == s);
                                    set square = Filtered(predicate(_), Board[r]); 
                                    set wasPlaced += square;
                                    let q = square[0];
                                    set done = true;
                                
                                    let i = IndexOf((a) -> (q == a), needsPlaced);
                                    if i > -1 {
                                        set needsPlaced = Swapped(0, i, needsPlaced);
                                        set needsPlaced = Subarray(RangeAsIntArray(1..(Length(needsPlaced)-1)), needsPlaced);
                                    }
                                }
                            }
                        }
                    }
                }

                set board w/= r <- square;
            }

        }
                
        //if 
        return (idx, board);
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
