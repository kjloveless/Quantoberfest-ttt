namespace QubitQFT {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;

    @EntryPoint()
    operation Perform3qubitQFT() : Result[] {
      mutable resultArray = [Zero, size = 3];
      use qs = Qubit[3];

      H(qs[0]);

      Controlled R1([qs[1]], (PI()/2.0, qs[0]));
      Controlled R1([qs[2]], (PI()/4.0, qs[0]));

      H(qs[1]);
      Controlled R1([qs[2]], (PI()/2.0, qs[1]));

      H(qs[2]);

      SWAP(qs[2], qs[0]);

      Message("Before measurement: ");
      DumpMachine();

      for i in IndexRange(qs) {
        set resultArray w/= i <- M(qs[i]);
      }

      Message("After measurement :");
      DumpMachine();

      ResetAll(qs);
      return resultArray;
    }
    
    operation HelloQ() : Unit {
        Message("Hello quantum world!");
    }
}

