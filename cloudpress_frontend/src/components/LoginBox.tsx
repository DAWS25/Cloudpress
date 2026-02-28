import { login, logout } from '../auth'

type Props = {
  user: string | null
  setUser: (user: string | null) => void
}

export default function LoginBox({ user, setUser }: Props) {
  return (
    <section className="card login">
      {!user ? (
        <>
          <h3>🔐 Acesse sua conta</h3>
          <button onClick={login}>Entrar com Cognito</button>
        </>
      ) : (
        <>
          <h3>👤 Sessão ativa</h3>
          <p>{user}</p>
          <button onClick={() => {
            logout()
            setUser(null)
          }}>
            Logout</button>
        </>
      )}
    </section>
  )
}
