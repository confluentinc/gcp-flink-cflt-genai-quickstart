import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import logo from '../assets/logo.png'
import { useNavigate } from 'react-router-dom'

export const Navbar = () => {
  const navigate = useNavigate()

  const handleLogout = () => {
    // Clear the authentication data
    localStorage.removeItem('isAuthenticated')
    // Redirect to the login page
    navigate('/login')
  }

  const handleHelp = () => {
     // Programmatically navigate to the help page
     navigate('/help')
  }

  return (
    <nav className="fixed top-0 w-full bg-[#1579a7] z-50 border-b">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between bg-[#1579a7] text-white">
        <Link
          to="/"
          className="flex items-center gap-2 text-xl font-semibold text-white hover:opacity-80 transition-opacity"
        >
          <img
            src={logo}
            alt="Logo"
            className="w-10 h-10"
          />
          <span className="font-montserrat font-bold tracking-wide">Confluent HealthCare AI</span>
        </Link>
        <div className="flex items-center gap-4">
          {location.pathname !== '/login' && (
           <>
                 <Button
                        size="sm"
                        className="bg-[#59a9ce] hover:bg-[#59a9ce]/90 text-[#fff] transition-colors"
                        onClick={handleHelp}
                     >
                       💡 Help
                 </Button>
                 <Button
                    size="sm"
                    className="bg-[#59a9ce] hover:bg-[#59a9ce]/90 text-[#fff] transition-colors"
                    onClick={handleLogout}
                 >
                    Logout
                 </Button>
           </>
          )}
        </div>
      </div>
    </nav>
  )
}
