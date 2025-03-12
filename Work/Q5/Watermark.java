import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

public class Watermark {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java Watermark <imagesDir> <watermarkText>");
            System.exit(1);
        }

        String imagesDir = args[0];
        String watermarkText = args[1];

        File dir = new File(imagesDir);
        if (!dir.exists() || !dir.isDirectory()) {
            System.out.println("Invalid directory: " + imagesDir);
            System.exit(1);
        }

        File[] files = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".png"));
        if (files == null) {
            System.out.println("No PNG files found in " + imagesDir);
            return;
        }

        for (File imgFile : files) {
            try {
                BufferedImage image = ImageIO.read(imgFile);
                Graphics2D g2d = image.createGraphics();
                // Some simple styling
                g2d.setFont(new Font("Arial", Font.BOLD, 24));
                g2d.setColor(Color.RED);
                // Draw the text near the top-left corner
                g2d.drawString(watermarkText, 10, 30);
                g2d.dispose();

                String outputName = imgFile.getName();
                String outputPath = dir.getAbsolutePath() + "/watermarked_" + outputName;
                ImageIO.write(image, "png", new File(outputPath));

                System.out.println("Watermarked: " + outputPath);
            } catch (Exception e) {
                System.out.println("Failed to process " + imgFile.getName() + ": " + e);
            }
        }
    }
}
