# SpringSecurity认证CAS调用流程

- 接口调用过程

AuthenticationFilter -> AuthenticationManager -> AuthenticationProvider -> TicketValidator&AuthenticationUserDetailsService、

```java
/**
 *   CasAuthenticationFilter#attemptAuthentication
 *   ↓
 *   ProviderManager#authenticate
 *   ↓
 *   CasAuthenticationProvider#authenticate -> #authenticateNow
 *   ↓
 *   Cas20ServiceTicketValidator
 *   ↓
 *   CustomAuthenticationUserDetailsService
 */
```