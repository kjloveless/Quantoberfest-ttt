namespace Bell {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    operation SetQubitState(desired : Result, target : Qubit) : Unit {
      if desired != M(target) {
        X(target);
      }
    }

    @EntryPoint()
    operation TestBellState(count : Int, initial : Result): (Int, Int, Int, Int) {
      mutable numOnesQ1 = 0;
      mutable numOnesQ2 = 0;

      // alloc qubits
      use (q1, q2) = (Qubit(), Qubit());
      for test in 1..count {
        SetQubitState(initial, q1);
        SetQubitState(Zero, q2);

        H(q1); // Add the H operation after initialization and before measurement.
        CNOT(q1, q2); // Add the CNOT operation after the H operation
        
        // measure each qubit
        let resultQ1 = M(q1);
        let resultQ2 = M(q2);

        // Count the number of 'Ones' we saw:
        if resultQ1 == One {
          set numOnesQ1 += 1;
        }
        if resultQ2 == One {
          set numOnesQ2 += 1;
        }
      }

      // reset the qubits
      SetQubitState(Zero, q1);
      SetQubitState(Zero, q2);

      // Return times we saw |0>, times we saw |1>
      Message("q1:Zero, One   q2:Zero, One");
      return (count - numOnesQ1, numOnesQ1, count - numOnesQ2, numOnesQ2);
    }   

    operation HelloQ() : Unit {
        Message("Hello Bell!");
    }
}

