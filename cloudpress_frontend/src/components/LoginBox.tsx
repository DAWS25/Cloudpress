export default function LoginBox() {
  return (
    <section className="card login">
      <h3>🔐 Acesse sua conta</h3>

      <input type="email" placeholder="E-mail" />
      <input type="password" placeholder="Senha" />

      <button>Entrar</button>
      <small>Esqueceu sua senha?</small>
    </section>
  )
}
