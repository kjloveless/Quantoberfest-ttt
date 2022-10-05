namespace tic_tac_toe {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    
    @EntryPoint()
    operation SayHello() : Unit {
        for i in 1..10 {
            use qubits = Qubit[4];            
            let size1 = CollapseSquare(qubits[0..0]);
            let size2 = CollapseSquare(qubits[0..1]);
            let size3 = CollapseSquare(qubits[0..2]);        
            let size4 = CollapseSquare(qubits);

            Message($"1 Piece : {size1} \t 2 Pieces : {size2} \t 3 Pieces : {size3} \t 4 Pieces : {size4}");
        }
    }

    //Collapse the entangled Xs and Os on a square.
    //Returned is the index of the piece that gets to claim the square.
    //Only works for up to 4 entangled pieces in a square.
    operation CollapseSquare(qubits : Qubit[]) : Int {
        let len = Length(qubits);
        if len == 1 { return 0; }
        H(qubits[0]);
        CNOT(qubits[0], qubits[1]);
        X(qubits[1]);
        if len > 2 {
            H(qubits[1]);
            CNOT(qubits[0], qubits[2]);
            CNOT(qubits[1], qubits[2]);
            X(qubits[2]);
        }
        let outcome = MeasureEachZ(qubits);
        ResetAll(qubits);

        for i in 0..(len-1) {
            if len == 2 { 
                if outcome[i] == One {
                    return i;
                }
			} elif outcome[i] == Zero {

            } else {
                if outcome[0] == One and outcome[1] == One {
                    if len == 3 {
                        return CollapseSquare(qubits);
                    }
                    return 3;
                } else {
                    return i;
                }
            }
        }
                
        return -1;
    }
}
