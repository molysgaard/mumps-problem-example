use russell_lab::{Matrix, Vector};
use russell_sparse::{ConfigSolver, Solver, SparseTriplet, Symmetry, StrError};

fn main() -> Result<(), StrError> {
    // allocate a square matrix
    let mut trip = SparseTriplet::new(3, 3, 5, Symmetry::No)?;
    trip.put(0, 0, 0.2)?;
    trip.put(0, 1, 0.2)?;
    trip.put(1, 0, 0.5)?;
    trip.put(1, 1, -0.25)?;
    trip.put(2, 2, 0.25)?;

    // print matrix
    let (m, n) = trip.dims();
    let mut a = Matrix::new(m, n);
    trip.to_matrix(&mut a)?;
    let correct = "┌                   ┐\n\
                   │   0.2   0.2     0 │\n\
                   │   0.5 -0.25     0 │\n\
                   │     0     0  0.25 │\n\
                   └                   ┘";
    assert_eq!(format!("{}", a), correct);

    // allocate rhs
    let rhs1 = Vector::from(&[1.0, 1.0, 1.0]);
    let rhs2 = Vector::from(&[2.0, 2.0, 2.0]);

    // calculate solution
    let config = ConfigSolver::new();
    let (mut solver, x1) = Solver::compute(config, &trip, &rhs1)?;
    let correct1 = "┌   ┐\n\
                    │ 3 │\n\
                    │ 2 │\n\
                    │ 4 │\n\
                    └   ┘";
    assert_eq!(format!("{}", x1), correct1);

    // solve again
    let mut x2 = Vector::new(trip.dims().0);
    solver.solve(&mut x2, &rhs2)?;
    let correct2 = "┌   ┐\n\
                    │ 6 │\n\
                    │ 4 │\n\
                    │ 8 │\n\
                    └   ┘";
    assert_eq!(format!("{}", x2), correct2);
    Ok(())
}