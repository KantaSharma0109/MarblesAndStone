part of common;

class AlertMessages {
  static String getMessage(int id) {
    switch (id) {
      //Common Messages
      case 1:
        return 'Please login to pay';

      default:
        return '';
    }
  }
}
