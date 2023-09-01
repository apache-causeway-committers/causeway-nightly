import java.io.File;
import java.io.IOException;
import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Optional;

class RemoveBinariesOlderThan {

    static void remove(final File root, final LocalDate cutOffDateSoft, final LocalDate cutOffDateHard) throws IOException {
    
    	System.out.printf("processing %s%n", root.getAbsolutePath());
    
        Files.find(root.toPath(), Integer.MAX_VALUE, (path, attr)->{
            return attr.isDirectory();
        }, FileVisitOption.FOLLOW_LINKS)
        .map(Path::toFile)
        .forEach(dir->{
            var dateIfAny = parseDateFromDirectoryName(dir.getName());
            dateIfAny
            .filter(date->date.isBefore(cutOffDateHard)
                   || (
                       date.isBefore(cutOffDateSoft)
                        && !isSunday(date) ))
            .ifPresent(date->{
                if(deleteDirectory(dir)) {
                    System.out.printf("pruning %s OK%n", dir);
                } else {
                    System.out.printf("pruning %s FAILED%n", dir);
                }
            });

            if(dir.exists()
                && ( dir.getName().equals("2.0.0-SNAPSHOT")
                        || dir.getName().equals("3.0.0-SNAPSHOT"))) {
                if(deleteDirectory(dir)) {
                    System.out.printf("pruning %s OK%n", dir);
                } else {
                    System.out.printf("pruning %s FAILED%n", dir);
                }
            }
            
        });
    }

    static Optional<LocalDate> parseDateFromDirectoryName(final String dir) {

        final int len = dir.length();
        if(len<=22) {
            return Optional.empty();
        }
        final int q = len-14;
        final int p = q-8;

        var dateLiteral = dir.substring(p, q);

        if(dateLiteral.chars()
            .filter(Character::isDigit)
            .count() != 8L) {
            return Optional.empty();
        }

        return Optional.of(LocalDate.of(
                Integer.valueOf(dateLiteral.substring(0, 4)),
                Integer.valueOf(dateLiteral.substring(4, 6)),
                Integer.valueOf(dateLiteral.substring(6, 8))));
    }

    static boolean deleteDirectory(final File directoryToBeDeleted) {
        File[] allContents = directoryToBeDeleted.listFiles();
        if (allContents != null) {
            for (File file : allContents) {
                deleteDirectory(file);
            }
        }
        return directoryToBeDeleted.delete();
    }
    
    static boolean isSunday(final LocalDate date) {
        return date.getDayOfWeek().equals(DayOfWeek.SUNDAY);
    }
}
   
RemoveBinariesOlderThan.remove(
        new File("."), // current dir
        LocalDate.now().minusWeeks(8), // remove all (older than) except sunday builds
        LocalDate.now().minusWeeks(32) // remove all (older than)
);
        
System.out.println("done.");
    
/exit
