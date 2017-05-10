
public class Project {
    
    public static double tan(double x) {
        return sin(x) / cos(x);
    }
    
    public static double sin(double x) {
        return cos(x - Math.PI / 2);
    }
    
    public static double cos(double x) {
        if(x < 0) {
            x = -x;
        }
        int n = (int)(x / (2 * Math.PI));
        x = x - n * (2 * Math.PI); //x is in [0;2pi)
        if(x < Math.PI / 2) {
            return cos0(x);
        }
        else if(x < Math.PI) {
            return -cos0(Math.PI - x);
        }
        else {
            return -cos0(x - Math.PI);
        }
    }
    
    public static double cos0(double x) {
        int loops = 40;
        double result = 1;
        double last = 1;
        double pow = x*x;
        int sign = -1;
        int n = 2;
        while(loops > 0) {
            int v = n;
            v = v * --n;
            last = last / (double)v;
            last = last * pow;
            result += last * sign;
            sign = -sign;
            n += 3;
            loops--;
        }
        return result;
    }
}
