import java.util.*;

// A program to work with Mini-Git. Manages the state of repositories and allows for all
// operations defined in Mini-Git.
public class Client {
    private static List<String> ops = new ArrayList<>();

    public static void main(String[] args) {
        Collections.addAll(ops, "create", "head", "history", "commit", "drop",
                           "synchronize", "quit");
        Scanner console = new Scanner(System.in);
        Map<String, Repository> repos = new HashMap<>();
        String op = "";
        String name = "";

        intro();

        while (!op.equalsIgnoreCase("quit")) {
            System.out.println("Available repositories: ");
            for (Repository repo : repos.values()) {
                System.out.println("\t" + repo);
            }
            System.out.println("Operations: " + ops);
            System.out.print("Enter operation and repository: ");
            String[] input = console.nextLine().split("\\s+");
            op = input[0];
            name = input.length > 1 ? input[1] : "";
            while (!ops.contains(op) || (!op.equalsIgnoreCase("create") &&
                    !op.equalsIgnoreCase("quit") &&
                    !repos.containsKey(name))) {
                System.out.println("  **ERROR**: Operation or repository not recognized.");
                System.out.print("Enter operation and repository: ");
                input = console.nextLine().split("\\s+");
                op = input[0];
                name = input.length > 1 ? input[1] : "";
            }

            Repository currRepo = repos.get(name);
            op = op.toLowerCase();
            if (op.equalsIgnoreCase("create")) {
                if (currRepo != null) {
                    System.out.println("  **ERROR**: Repository with that name already exists.");
                } else {
                    Repository newRepo = new Repository(name);
                    repos.put(name, newRepo);
                    System.out.println("  New repository created: " + newRepo);
                }
            } else if (op.equalsIgnoreCase("head")) {
                System.out.println(currRepo.getRepoHead());
            } else if (op.equalsIgnoreCase("history")) {
                System.out.print("How many commits back? ");
                int nHist = console.nextInt();
                console.nextLine();
                System.out.println(currRepo.getHistory(nHist));
            } else if (op.equalsIgnoreCase("commit")) {
                System.out.print("Enter commit message: ");
                String message = console.nextLine();
                System.out.println("  New commit: " + currRepo.commit(message));
            } else if (op.equalsIgnoreCase("drop")) {
                System.out.print("Enter ID to drop: ");
                String idDrop = console.nextLine();
                if (currRepo.drop(idDrop)) {
                    System.out.println("  Successfully dropped " + idDrop);
                } else {
                    System.out.println("  No commit dropped!");
                }
            } else if (op.equalsIgnoreCase("synchronize")) {
                System.out.print("Which repository would you like to " +
                        "synchronize into the given one? ");
                String repo = console.nextLine();
                if (repo.equals(name)) {
                    System.out.println("Cannot synchronize the same repositories!");
                } else if (!repos.containsKey(repo)) {
                    System.out.println("Repository does not exist!");
                } else {
                    currRepo.synchronize(repos.get(repo));
                }
            }
            System.out.println();
        }
    }

    // Prints out an introduction to the Mini-Git test client.
    public static void intro() {
        System.out.println("Welcome to the Mini-Git test client!");
        System.out.println("Use this program to test your Mini-Git repository implemenation.");
        System.out.println("Make sure to test all operations in all cases --");
        System.out.println("some cases are particularly tricky.");
        System.out.println();
    }
}

import java.text.SimpleDateFormat;

/*
This is the Repository Class. Within are methods that revolve around the Repository
object, following its creation. The Repository is an object that stores the Commit objects
in a LinkNode fashion. Utilizes the Commit object created in the Commit class,
which is contained in this one.
*/
public class Repository {

    private String name;
    private Commit head;

    /*
    Behavior: Creates a new, empty Repository object.
    Exceptions: Throws the IllegalArgumentException if the parameter String is null or empty.
    Returns: none.
    Parameter: the String representing the name of the repository.
    */
    public Repository(String name) throws IllegalArgumentException {
        if(name == null || name.isEmpty()) {
            throw new IllegalArgumentException();
        }
        this.name = name;
        this.head = null;
    }

    /*
    Behavior: produces the id of the current head of the repository 
    Exceptions: none.
    Returns: String representing the ID of the head of the Repository. 
                will be null if the head of the repository is null.
    Parameter: none.
    */
    public String getRepoHead() {
        return (head != null) ? head.id : null;
    }

    /*
    Behavior: calculates the number of commits of the repository.
    Exceptions: none.
    Returns: the integer representing the size of the Repository.
    Parameter: none
    */
    public int getRepoSize() {
     int size = 0;
        Commit current = head;
        while(current != null) {
            size++;
            current = current.past;
        }
        return size;
    }

    /*
    Behavior: Creates a special formatting of the commits for the client.
                format: "<name> - Current head: <current head>"
                or "<name> - no commits" if there are no commits.
    Exceptions: none.
    Returns: The String representing the commits for the client. See the
                behavior part for the formatting of the return.
    Parameter: none.
    */
    public String toString() {
        if (head == null) {
            return name + " - No commits";
        }
        return name + " - Current head: " + head.toString();
    }

    /*
    Behavior: Tells the client whether or not the repository contains 
                a commit with the desired ID.
    Exceptions: no exceptions thrown
    Returns: true if there is an entry with the matching ID, false if not.
    Parameters: The String representing the desired ID.
    */
    public boolean contains(String targetId) {
        Commit current = head;
        while(current != null) {
            if(current.id.equals(targetId)) {
                return true;
            }
            current = current.past;
        }
        return false;
    }

    /*
    Behavior: Displays the latest desired commits for the client to see.
    Exceptions: Throws the IllegalArgumentException if the n provided
                    is less than or equal to 0
    Returns: Returns the String representing the latest n amount of commits. if
                n is greater than the total number of commits, it will return every 
                available entry for the client. The return will be empty if there
                are no commits in the repository.
    Parameters: The integer n representing the last desired n amount of commits in the history.
    */
    public String getHistory(int n) throws IllegalArgumentException {
        if (n <= 0) {
            throw new IllegalArgumentException();
        }
        String history = "";
        Commit current = head;
        int count = 0;
        int times = Math.min(getRepoSize(), n);
        while (current != null && count < n) {
            history += current.toString() + "\n";
            current = current.past;
            count++;
        }
        return history;
    }

    /*
    Behavior: Creates a new commit with the String message parameter. this new commit
                also becomes the new head, and points towards the previous head, 
                preserving the history.
    Exceptions: none.
    Returns:  the String representing the ID of the created Commit.
    Parameters: The String representing the message that is put into the Commit.
    */
    public String commit(String message) {
        Commit comm = new Commit(message, this.head);
        this.head = comm;
        return comm.id;
    }

    /*
    Behavior: Accepts a target id and will search for it within the repository.
                if it exists, that commit will be removed from the Repository. 
                nothing will change if the id was not found in a commit in the 
                Repository.
    Exceptions: no exceptions thrown
    Returns: true if the target ID has been found and removed, 
                    and false if it is not in the repository.
    Parameters: the String representing the target ID.
    */
    public boolean drop(String targetId) { 
        if (head == null) {
            return false;
        }
        if (head.id.equals(targetId)) {
            head = head.past;
            return true;
        }
        Commit currentCommit = head;
        while (currentCommit.past != null && !currentCommit.past.id.equals(targetId)) {
            currentCommit = currentCommit.past;
        }
        if (currentCommit.past != null) {
            currentCommit.past = currentCommit.past.past;
            return true;
            }
        return false;
    }

    /*
    Behavior: takes a secondary repository and moves all of the commits from that one
                to the current Repository, while preserving chronological time order.
                empties out the secondary Repository through this process. If the secondary
                repository is empty, nothing will change to the current one.
    Exceptions: no exceptions thrown.
    Returns: void, no returns.
    Paramaters: a secondary repository for which to synchronize with the current one
    */
    public void synchronize(Repository other) {
        boolean continueSynchronization = true;

        while (continueSynchronization) {
            if (other.head == null) {
                continueSynchronization = false;
            }

            if (head == null) {
                head = other.head;
                other.head = null;
                continueSynchronization = false;
            }

            Commit currentThis = head;
            Commit currentOther = other.head;
            Commit previousThis = null;

            while (currentOther != null) {
                if (currentThis == null || currentOther.timeStamp >= currentThis.timeStamp) {
                    Commit nextOther = currentOther.past;
                    currentOther.past = currentThis;

                    if (previousThis != null) {
                        previousThis.past = currentOther;
                    } 
                    else {
                        head = currentOther;
                        }

                    previousThis = currentOther;
                    currentOther = nextOther;
                } 
                else {
                    previousThis = currentThis;
                    currentThis = currentThis.past;
                }
            }
            other.head = null;
            continueSynchronization = false;
        }
    }

    /**
     * DO NOT MODIFY
     * A class that represents a single commit in the repository.
     * Commits are characterized by an identifier, a commit message,
     * and the time that the commit was made. A commit also stores
     * a reference to the immediately previous commit if it exists.
     *
     * Staff Note: You may notice that the comments in this 
     * class openly mention the fields of the class. This is fine 
     * because the fields of the Commit class are public. In general, 
     * be careful about revealing implementation details!
     */
    public class Commit {

        private static int currentCommitID;

        /**
         * The time, in milliseconds, at which this commit was created.
         */
        public final long timeStamp;

        /**
         * A unique identifier for this commit.
         */
        public final String id;

        /**
         * A message describing the changes made in this commit.
         */
        public final String message;

        /**
         * A reference to the previous commit, if it exists. Otherwise, null.
         */
        public Commit past;

        /**
         * Constructs a commit object. The unique identifier and timestamp
         * are automatically generated.
         * @param message A message describing the changes made in this commit.
         * @param past A reference to the commit made immediately before this
         *             commit.
         */
        public Commit(String message, Commit past) {
            this.id = "" + currentCommitID++;
            this.message = message;
            this.timeStamp = System.currentTimeMillis();
            this.past = past;
        }

        /**
         * Constructs a commit object with no previous commit. The unique
         * identifier and timestamp are automatically generated.
         * @param message A message describing the changes made in this commit.
         */
        public Commit(String message) {
            this(message, null);
        }

        /**
         * Returns a string representation of this commit. The string
         * representation consists of this commit's unique identifier,
         * timestamp, and message, in the following form:
         *      "[identifier] at [timestamp]: [message]"
         * @return The string representation of this collection.
         */
        @Override
        public String toString() {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd 'at' HH:mm:ss z");
            Date date = new Date(timeStamp);

            return id + " at " + formatter.format(date) + ": " + message;
        }

        /**
        * Resets the IDs of the commit nodes such that they reset to 0.
        * Primarily for testing purposes.
        */
        public static void resetIds() {
            Commit.currentCommitID = 0;
        }
    }
}

import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import java.util.*;

public class RepositoryTest {
    private Repository repo1;
    private Repository repo2;

    /**
     * NOTE: The following test suite assumes that getRepoHead(), commit(), and size()
     *       are implemented correctly.
     */

    @BeforeEach
    public void setUp() {
        repo1 = new Repository("repo1");
        repo2 = new Repository("repo2");
        Repository.Commit.resetIds();
    }

    @Test
    @DisplayName("Test getHistory()")
    public void getHistory() {
        // Initialize commit messages
        String[] commitMessages = new String[]{"Initial commit.", "Updated method documentation.",
                                                "Removed unnecessary object creation."};

        // Commit the commit messages to repo1
        for (int i = 0; i < commitMessages.length; i++) {
            String commitMessage = commitMessages[i];
            repo1.commit(commitMessage);

            // Assert that the current commit id is at the repository's head
            // We know our ids increment from 0, meaning we can just use i as our id
            assertEquals("" + i, repo1.getRepoHead());
        }

        assertEquals(repo1.getRepoSize(), commitMessages.length);

        // This is the method we are testing for. First, we'll obtain the 2 most recent commits
        // that have been made to repo1.
        String repositoryHistory = repo1.getHistory(2);
        String[] commits = repositoryHistory.split("\n");

        // Verify that getHistory() only returned 2 commits.
        assertEquals(commits.length, 2);

        // Verify that the 2 commits have the correct commit message and commit id
        for (int i = 0; i < commits.length; i++) {
            String commit = commits[i];

            // Old commit messages/ids are on the left and the more recent commit messages/ids are
            // on the right so need to traverse from right to left to ensure that 
            // getHistory() returned the 2 most recent commits.
            int backwardsIndex = (commitMessages.length - 1) - i;
            String commitMessage = commitMessages[backwardsIndex];

            assertTrue(commit.contains(commitMessage));
            assertTrue(commit.contains("" + backwardsIndex));
        }
    }

    @Test
    @DisplayName("Test drop() (empty case)")
    public void testDropEmpty() {
        assertFalse(repo1.drop("123"));
    }

    @Test
    @DisplayName("Test drop() (front case)")
    public void testDropFront() {
        assertEquals(repo1.getRepoSize(), 0);
        // Initialize commit messages
        String[] commitMessages = new String[]{"First commit.", "Added unit tests."};

        // Commit to repo1 - ID = "0"
        repo1.commit(commitMessages[0]);

        // Commit to repo2 - ID = "1"
        repo2.commit(commitMessages[1]);

        // Assert that repo1 successfully dropped "0"
        assertTrue(repo1.drop("0"));
        assertEquals(repo1.getRepoSize(), 0);
        
        // Assert that repo2 does not drop "0" but drops "1"
        // (Note that the commit ID increments regardless of the repository!)
        assertFalse(repo2.drop("0"));
        assertTrue(repo2.drop("1"));
        assertEquals(repo2.getRepoSize(), 0);
    }
}
