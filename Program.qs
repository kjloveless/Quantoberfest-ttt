namespace tic_tac_toe {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    
    @EntryPoint()
    operation SayHello() : Unit {
        let (q1Zero, q1One, q2Zero, q2One, q3Zero, q3One) = TestBellState(4000, One);
        Message($"{q1Zero}, {q1One}   {q2Zero}, {q2One}   {q3Zero}, {q3One}");
    }

    operation TestBellState(count : Int, initial : Result) : (Int, Int, Int, Int, Int, Int) {
        mutable numOnesQ1 = 0;
        mutable numOnesQ2 = 0;
        mutable numOnesQ3 = 0;

        // allocate the qubits
        use qArray = Qubit[3];
        use qReg = Qubit[3];
        for test in 1..count {
            SetQubitState(initial, qArray[0]);
            SetQubitState(initial, qArray[1]);
            SetQubitState(initial, qArray[2]);

            H(qArray[0]);
            CNOT(qArray[0], qArray[1]);
            CNOT(qArray[0], qArray[2]);
            CNOT(qArray[1], qArray[2]);
        
            // measure each qubit
            let resultQ1 = M(qArray[0]);            
            let resultQ2 = M(qArray[1]);
            let resultQ3 = M(qArray[2]);

            // Count the number of 'Ones':
            if resultQ1 == One {
                set numOnesQ1 += 1;
            }
            if resultQ2 == One {
                set numOnesQ2 += 1;
            }
            if resultQ3 == One {
                set numOnesQ3 += 1;
            }
        }        

        // reset the qubits
        ResetAll(qArray);

        // Return number of |0> states, number of |1> states
        Message("q1:Zero, One  q2:Zero, One  q3:Zero, One");
        return (count - numOnesQ1, numOnesQ1, count - numOnesQ2, numOnesQ2, count - numOnesQ3, numOnesQ3);
    }

    operation SetQubitState(desired : Result, target : Qubit) : Unit {
        if desired != M(target) {
            X(target);
        }
    }
}
