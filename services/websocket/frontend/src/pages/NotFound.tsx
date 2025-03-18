import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { AlertTriangle, Home } from "lucide-react";
import { Link } from "react-router-dom";

const NotFound = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-white to-gray-50 p-4">
      <Card className="w-full max-w-md shadow-lg">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 bg-yellow-50 p-3 rounded-full">
            <AlertTriangle className="h-12 w-12 text-yellow-500" />
          </div>
          <CardTitle className="text-2xl font-bold">Page Not Found</CardTitle>
          <CardDescription>
            The page you are looking for doesn't exist or has been moved.
          </CardDescription>
        </CardHeader>
        <CardContent className="text-center text-muted-foreground">
          <p>
            Sorry, we couldn't find the page you were trying to reach. Please check the URL or navigate back to the home page.
          </p>
        </CardContent>
        <CardFooter className="flex justify-center">
          <Button asChild>
            <Link to="/" className="flex items-center gap-2">
              <Home className="h-4 w-4" />
              Return Home
            </Link>
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
};

export default NotFound;