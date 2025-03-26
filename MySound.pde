import javax.sound.sampled.*;

// Limitation: cannot play multiple instances of the same sound at the same time.
//  Not sure how I'd fix that, yet...

//maybe i can make multiple slots in every sound
//and then it can fill up a couple
//like a queue
//or a stack might be better actually
//or just a rotating% array

class MySound {
  Clip clip;
  
  MySound(String filePath) {
    InputStream inputStream = createInput(filePath);
    try {
      clip = AudioSystem.getClip();
      AudioInputStream ais = AudioSystem.getAudioInputStream(inputStream);
      clip.open(ais);
    }
    catch (Exception e) {
      println(e);
    }
  }

  void play() {
    clip.setFramePosition(0);
    clip.start();
  }
}
