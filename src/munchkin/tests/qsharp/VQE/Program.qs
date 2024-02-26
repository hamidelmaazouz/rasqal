﻿namespace Microsoft.Quantum.Chemistry.VQE {

open Microsoft.Quantum.Core;
open Microsoft.Quantum.Chemistry;
open Microsoft.Quantum.Chemistry.JordanWigner;
open Microsoft.Quantum.Chemistry.JordanWigner.VQE;
open Microsoft.Quantum.Intrinsic;
    
    operation GetEnergyVQE (JWEncodedData: JordanWignerEncodingData, theta1: Double, theta2: Double, theta3: Double, nSamples: Int) : Double {
        let (nSpinOrbitals, fermionTermData, inputState, energyOffset) = JWEncodedData!;
        let (stateType, JWInputStates) = inputState;
        let inputStateParam = (
            stateType,
        [
            JordanWignerInputState((theta1, 0.0), [2, 0]), // singly-excited state
            JordanWignerInputState((theta2, 0.0), [3, 1]), // singly-excited state
            JordanWignerInputState((theta3, 0.0), [2, 3, 1, 0]), // doubly-excited state
            JWInputStates[0] // Hartree-Fock state from Broombridge file
        ]
        );
        let JWEncodedDataParam = JordanWignerEncodingData(
            nSpinOrbitals, fermionTermData, inputState, energyOffset
        );
        return EstimateEnergy(
            JWEncodedDataParam, nSamples
        );
    }
}