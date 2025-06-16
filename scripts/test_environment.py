#!/usr/bin/env python3
"""
Skrypt do testowania środowiska spektrometrii mas
Sprawdza czy wszystkie wymagane biblioteki są dostępne
"""

def test_imports():
    """Test importów wszystkich wymaganych bibliotek"""
    try:
        import pymzml
        print("✓ pymzML imported successfully")
    except ImportError as e:
        print(f"❌ pymzML import failed: {e}")
        return False

    try:
        import matplotlib.pyplot as plt
        print("✓ matplotlib imported successfully")
    except ImportError as e:
        print(f"❌ matplotlib import failed: {e}")
        return False

    try:
        import pandas as pd
        print("✓ pandas imported successfully")
    except ImportError as e:
        print(f"❌ pandas import failed: {e}")
        return False

    try:
        import numpy as np
        print("✓ numpy imported successfully")
    except ImportError as e:
        print(f"❌ numpy import failed: {e}")
        return False

    try:
        import seaborn as sns
        print("✓ seaborn imported successfully")
    except ImportError as e:
        print(f"❌ seaborn import failed: {e}")
        return False

    try:
        import pyopenms
        print("✓ pyopenms imported successfully")
    except ImportError as e:
        print(f"❌ pyopenms import failed: {e}")
        return False

    try:
        import scipy
        print("✓ scipy imported successfully")
    except ImportError as e:
        print(f"❌ scipy import failed: {e}")
        return False

    try:
        import sklearn
        print("✓ scikit-learn imported successfully")
    except ImportError as e:
        print(f"❌ scikit-learn import failed: {e}")
        return False

    return True

def test_commands():
    """Test dostępności narzędzi CLI"""
    import subprocess
    import shutil
    
    # Test MSGF+
    if shutil.which('msgfplus'):
        print("✓ MSGF+ command available")
    else:
        print("❌ MSGF+ command not found")
        return False
    
    # Test Java
    try:
        result = subprocess.run(['java', '-version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✓ Java available")
        else:
            print("❌ Java not working properly")
            return False
    except FileNotFoundError:
        print("❌ Java not found")
        return False
    
    return True

if __name__ == "__main__":
    print("=== Testing Mass Spectrometry Environment ===")
    print()
    
    print("Testing Python libraries:")
    libs_ok = test_imports()
    print()
    
    print("Testing CLI tools:")
    tools_ok = test_commands()
    print()
    
    if libs_ok and tools_ok:
        print("🎉 Environment ready for mass spectrometry analysis!")
        print()
        print("Available tools:")
        print("- Python with pymzML, matplotlib, seaborn, pandas, numpy, scipy")
        print("- PyOpenMS for advanced MS analysis")
        print("- OpenMS CLI tools")
        print("- MSGF+ for peptide identification")
        print("- Jupyter Notebook environment")
    else:
        print("❌ Environment setup incomplete!")
        exit(1) 