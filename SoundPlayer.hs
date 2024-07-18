module SoundPlayer where

import Clash.Annotations.TH
import Clash.Prelude
import Data.Maybe (fromMaybe)
import Debug.Trace
import RetroClash.Utils (succIdx, withResetEnableGen)

-- | Setup the global clock
createDomain vSystem{vName = "AudioDom", vPeriod = hzToPeriod 44100}

-- | Sound position in a 1 second demo at 44100 Hz
type SoundPos = Index 44100

sawOsc :: SoundPos -> Signed 8
sawOsc pos = fromIntegral val
  where
    val, pitch, period :: Signed 32
    val = (fromIntegral pos `mod` period) * 255 `div` period
    period = 44100 `div` pitch
    pitch
        | pos > 20_000 = 500
        | pos > 12_000 = 480
        | otherwise = 440


-- | Produce a sample for the given position in the sound
sinOsc :: SoundPos -> Signed 8
sinOsc pos = mySin $ resize val
  where
    val = fromIntegral pos * pitch
    pitch :: Signed 32
    pitch
        | pos > 20_000 = 500
        | pos > 12_000 = 480
        | otherwise = 440

-- TODO! Function to compute roughly 127.5 + 127.5 * sin(2pi * val / 256)
mySin :: Signed 8 -> Signed 8
mySin = resize . rawSin . resize

{- | Borrowed from: https://github.com/MichaelBell/tt08-pwm-example/blob/main/src/sine.v
import math
def gen():
        resolution = 64
        scale = 127
        start = 0.5 - math.asin(1/(2*scale))*resolution
        end = resolution - 0.5
        for i in range(resolution):
            x = start + (end - start) * i / (resolution - 1)
            val = int(round(math.sin(x*math.pi/(2*resolution))*scale))
            print(f"rawSin {i} = {val}")
|
-}
rawSin :: Signed 7 -> Signed 7
rawSin 0 = 1
rawSin 1 = 4
rawSin 2 = 7
rawSin 3 = 10
rawSin 4 = 13
rawSin 5 = 16
rawSin 6 = 19
rawSin 7 = 23
rawSin 8 = 26
rawSin 9 = 29
rawSin 10 = 32
rawSin 11 = 35
rawSin 12 = 38
rawSin 13 = 41
rawSin 14 = 44
rawSin 15 = 47
rawSin 16 = 49
rawSin 17 = 52
rawSin 18 = 55
rawSin 19 = 58
rawSin 20 = 61
rawSin 21 = 63
rawSin 22 = 66
rawSin 23 = 69
rawSin 24 = 71
rawSin 25 = 74
rawSin 26 = 77
rawSin 27 = 79
rawSin 28 = 81
rawSin 29 = 84
rawSin 30 = 86
rawSin 31 = 88
rawSin 32 = 91
rawSin 33 = 93
rawSin 34 = 95
rawSin 35 = 97
rawSin 36 = 99
rawSin 37 = 101
rawSin 38 = 103
rawSin 39 = 105
rawSin 40 = 106
rawSin 41 = 108
rawSin 42 = 110
rawSin 43 = 111
rawSin 44 = 113
rawSin 45 = 114
rawSin 46 = 115
rawSin 47 = 117
rawSin 48 = 118
rawSin 49 = 119
rawSin 50 = 120
rawSin 51 = 121
rawSin 52 = 122
rawSin 53 = 123
rawSin 54 = 124
rawSin 55 = 124
rawSin 56 = 125
rawSin 57 = 125
rawSin 58 = 126
rawSin 59 = 126
rawSin 60 = 127
rawSin 61 = 127
rawSin 62 = 127
rawSin 63 = 127

-- | Generate the samples by keeping track of the position
-- TODO: handle clock division, instead of hardcoding 'AudioDom'
playSound :: (HiddenClockResetEnable AudioDom) => Signal AudioDom (Signed 8)
playSound = sawOsc <$> r
  where
    -- | Increment the position
    r :: Signal AudioDom SoundPos
    r = register 0 $ satSucc SatZero <$> r

-- | The final circuit
topEntity :: "CLK" ::: Clock AudioDom -> "OUT" ::: Signal AudioDom (Signed 8)
topEntity = withResetEnableGen playSound

makeTopEntity 'topEntity
