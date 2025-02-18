import { Navigate, useLocation } from 'react-router-dom';

function ProtectedRoute({ children }) {
  // Retrieve the authentication status from localStorage
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';

  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
}

export { ProtectedRoute }