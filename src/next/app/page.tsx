type Message = {
  message: string,
}

async function getMessage() {

  const res = await fetch(`${process.env.API_URL}/api/message`, {cache: "no-store"});
  const data:Message = await res.json();

  return data.message;
}

export default async function Home() {

  const message = await getMessage();

  return (
    <div>
      <h1>Next</h1>
      <h1>{message}</h1>
    </div>
  );
}
