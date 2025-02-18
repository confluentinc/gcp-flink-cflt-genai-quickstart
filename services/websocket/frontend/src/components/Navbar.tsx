import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button"; 
import logo from '../assets/confluent-logo-dark.png';
import { useNavigate } from 'react-router-dom';

export const Navbar = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Clear the authentication data
    localStorage.removeItem('isAuthenticated');
    // Redirect to the login page
    navigate('/login');
  };

  return (
    <nav className="fixed top-0 w-full bg-white/80 backdrop-blur-md z-50 border-b">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 text-xl font-semibold text-primary hover:opacity-80 transition-opacity">
          <img src={logo} alt="Logo" className="w-9 h-9" />
          Confluent HealthCare AI
        </Link>
        <div className="flex items-center gap-4">
        {location.pathname !== '/login' && (
            <>
              <Button size="lg" className="bg-red-500 hover:bg-primary/90 text-white transition-colors" onClick={handleLogout}>
                Logout
              </Button>
            </>
          )}
        </div>
      </div>
    </nav>
  );
};