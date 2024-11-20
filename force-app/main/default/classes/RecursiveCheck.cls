/*
 * @group service
 * @description recursive Check class
 * @author Cloud Peritus Inc
 * @created date (mm/dd/yyyy)
 * @last modified date
 */
public
class RecursiveCheck {
 private
  static boolean run = true;
  /*
   * @description run once method
   * @return boolean
   */
 public
  static boolean runOnce() {
    if (run) {
      run = false;
      return true;
    } else {
      return run;
    }
  }
}