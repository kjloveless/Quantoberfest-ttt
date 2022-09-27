namespace QCoin {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    
    @EntryPoint()
    operation FlipQoin(numTimes : Int) : Result[] {
      mutable resultArray = [Zero, size = numTimes];

      for i in IndexRange(resultArray) {
        use qubit = Qubit();
        H(qubit);
        set resultArray w/= i <- M(qubit); 
        ResetAll([qubit]);
      }
      return resultArray;      
    }
}

