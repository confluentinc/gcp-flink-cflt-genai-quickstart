import { Navbar } from "@/components/Navbar";
import { LoginForm } from "@/components/LoginForm";

const Login = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Navbar />
      <main className="container mx-auto px-4 pt-32 pb-16 flex justify-center">
        <LoginForm />
      </main>
    </div>
  );
};

export default Login;