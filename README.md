This file contains a few of the programming projects that I have completed at the University of Washington. The following files are in the repository:

1) Portfolio Analysis (ECON 424: Computational Finance and Financial Econometrics (R))
    - takes stock data from Starbucks, Amazon and a risk-free investment, and generates optimal portfolios for a consumer to maximize mean returns with
          minimum risk (standard deviation).
    - Analyzes the difference in optimal portfolios based on whether or not short sales are viable investments.
    - Computes the Sharpe ratio to identify the tangency portfolio, where the sharpe ratio is maximized (risk to return)
    - Finds the global minimum risk, where the safest portfolio is located

3) Node-Arc Incidence Matrix Data Project (AMATH 352: Applied Linear Algebra and Numerical Analysis(Python))
     - Takes a .txt file that details locations of nodes on a circuit board, as well as the charges moving between each node, and produces a schematic of the node,
         and the associated charge
     - Calculates the Node Arc Incidence matrix, representing the vertices and edges of the network
     - Produces matrices representing the currents and charges between each node
     - Determines the overall current that flows through the wires from source to sink, and identifies which node is the sink
     - Analyzes a data set to provide this information; does not come from a circuit that can be seen by the user

4) Repository (CSE 123: Introduction to Computer Programming III (Java))
     - Creates a Repository from scratch using LinkNode principles
     - Allows clients to create and drop commits, move them around, and attaches a unique ID to each one for indexing purposes
     - Users can search commits by id, receive the name, format, and ID of a desired commit
     - Users may also synchronize multiple repositories into a single one, which will preserve the time order associated with each commit,
           which is determined by each unique ID
     - J-Unit testing is included, to ensure that the repository produces the correct output for each method
