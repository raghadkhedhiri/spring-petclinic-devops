package org.springframework.samples.petclinic;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class SecurityHeadersFilter extends OncePerRequestFilter {

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {

		response.setHeader("Content-Security-Policy",
				"default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; "
						+ "img-src 'self' data:; font-src 'self' data:; object-src 'none'; "
						+ "base-uri 'self'; frame-ancestors 'none'; form-action 'self'");

		response.setHeader("X-Frame-Options", "DENY");
		response.setHeader("X-Content-Type-Options", "nosniff");

		filterChain.doFilter(request, response);
	}

}
